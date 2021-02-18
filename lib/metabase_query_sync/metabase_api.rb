# Lightweight metabase api interface to be just enough
# for this project.
class MetabaseQuerySync::MetabaseApi
  # collections

  def get_collection(id); throw; end
  def get_collection_items(collection_id); throw; end
  # @param collection_request [PutCollectionRequest]
  def put_collection(collection_request); throw; end

  # cards
  def get_card(id); throw; end
  # @param [PutCardRequest]
  def put_card(card_request); throw; end
  def delete_card(card_id); throw; end

  # pulses

  def find_pulse_by_name(name); throw; end
  # @param [PutPulseRequest]
  def put_pulse(pulse_request); throw; end
  def delete_pulse(pulse_id); throw; end

  # database

  # @return [Array<Database>]
  def get_databases(); throw; end

  # search
  def search(q, model: nil); throw; end

  private

  def throw
    raise 'not implemented'
  end
end