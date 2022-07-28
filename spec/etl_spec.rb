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
        expect(import.headers.to_a).to include(Etl::REQUIRED_HEADERS)
      end
    end
  end
  describe '.process_output' do

  end
end
