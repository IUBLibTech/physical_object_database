class SignalChainFormat < ActiveRecord::Base
  belongs_to :signal_chain
  validates :signal_chain, presence: true
  validates :format, presence: true, uniqueness: { scope: :signal_chain }
end
