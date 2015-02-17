xml.instruct! :xml, :version=>"1.0"

xml.metadata do
	unless @status = 200
		xml.failed @message
	else
		xml.decision @decision
	end
end