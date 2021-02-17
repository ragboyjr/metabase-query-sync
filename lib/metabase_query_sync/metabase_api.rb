# Lightweight metabase api interface to be just enough
# for this project.
class MetabaseQuerySync::MetabaseApi
  # collections

  # @return [Card, nil]
  def find_collection(id); throw; end
  # @return [Card, nil]
  def find_collection_by_name(name); throw; end
  # @return [Array<[Card, Pulse]>]
  def get_collection_items(collection_id); throw; end
  # @param collection_request [PutCollectionRequest]
  def put_collection(collection_request); throw; end
  def delete_collection(collection_id); throw; end

  # cards

  # @return [Card, nil]
  def find_card_by_name(name); throw; end
  # @param [PutCardRequest]
  def put_card(card_request); throw; end
  def delete_card(card_id); throw; end

  # pulses

  # @return [Pulse, nil]
  def find_pulse_by_name(name); throw; end
  # @param [PutPulseRequest]
  def put_pulse(pulse_request); throw; end
  def delete_pulse(pulse_id); throw; end

  private

  def throw
    raise 'not implemented'
  end
end