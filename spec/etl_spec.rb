require_relative '../Etl'

describe Etl do
  describe '.import_csv' do
    context 'when import_csv is called' do
      let(:import) { Etl.import_csv }

      it 'returns csv table' do
        expect(import).to be_kind_of(CSV::Table)
      end
      it 'processed 14 rows' do
        expect(import.size).to eq(14)
      end
      it 'set headers' do
        expect(import.headers.to_a).to include(:first_name)
        expect(import.headers.to_a).to include(:last_name)
        expect(import.headers.to_a).to include(:dob)
        expect(import.headers.to_a).to include(:expiry_date)
      end
    end
  end

  describe '.process_output' do
    context 'when called' do
      let(:import) {Etl.import_csv}
      let(:output) {Etl.process_output(import)}

      it 'processed' do
        expect(output).to be_kind_of(Array)
      end
    end
  end

  describe '.generate_report' do
    context 'when called' do
      let(:errors) { [{test: 'data'}, {test2: 'data2'}, {test3: 'data3'}] }

      it 'processed' do
        allow(Etl).to receive(:generate_report).and_return("Report")

        expect(Etl.generate_report(errors)).to eq('Report')
      end
    end
  end

  describe '.failed_check' do
    context 'when called' do
      let(:good_row) { {first_name:"Jason", last_name:"Bateman", dob:"12/12/2000", expiry_date: '01-23-23', member_id:"AB 0000", effective_date: "11/02/99",  phone_number: '555-555-5555'} }
      let(:bad_phone_row) { {first_name:"Jason", last_name:"Bateman", dob:"12/12/2000", expiry_date: '01-23-23', member_id:"AB 0000", effective_date: "11/02/99", phone_number: '123123'} }
      let(:missing_required_row) { {first_name:"Jason", dob:"12/12/2000", expiry_date: '01-23-23', member_id:"AB 0000", effective_date: "11/02/99"} }

      it 'when bad phone, true' do
        expect(Etl.failed_check(bad_phone_row)).to eq(true)
      end

      it 'when missing required, true' do
        expect(Etl.failed_check(missing_required_row)).to eq(true)
      end
    end
  end

  describe '.transform_date' do
    context 'when called transforms to iso8601' do
      let(:good_date) { '2/2/1966' }
      let(:weird_date) { '1/21/99'}
      let(:another_date) { '11-23-21' }

      it 'with a MM/DD/YYYY format' do
        expect(Etl.transform_date(good_date)).to eq('1966-02-02')
      end

      it 'with a MM/DD/YY format' do
        expect(Etl.transform_date(weird_date)).to eq('1999-01-21')
      end

      it 'with a MM-DD-YY format' do
        expect(Etl.transform_date(another_date)).to eq('2021-11-23')
      end
    end
  end

  describe '.transform_phone' do
    context 'when called transforms to E.164 compliant' do
      let(:easy_num) { '3032323242' }
      let(:weird_num) { '(303) 123 - 2123'}
      let(:dash_num) { '502-231-1234' }

      it 'should be transformed to e.164 compliant' do
        expect(Etl.transform_phone(easy_num)).to eq('+13032323242')
        expect(Etl.transform_phone(weird_num)).to eq('+13031232123')
        expect(Etl.transform_phone(dash_num)).to eq('+15022311234')
      end

    end
  end

  describe '.transform_all_date_fields' do
    context 'when called changes all dates in row to proper format' do
      let(:row) { {first_name:"Jason", last_name:"Bateman", dob:"12/12/2000", expiry_date: '01-23-23', member_id:"AB 0000", effective_date: "11/02/99"} }
      let(:transformed) { Etl.transform_all_date_fields(row) }

      it 'should  transform dates' do
        expect(transformed[:dob]).to eq('2000-12-12')
        expect(transformed[:expiry_date]).to eq('2023-01-23')
        expect(transformed[:effective_date]).to eq('1999-11-02')
      end
    end
  end


end
