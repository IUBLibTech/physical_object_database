module Sql

	def Sql.physical_object_query(physical_object)
		 "SELECT physical_object.* FROM physical_objects, technical_metadata, #{tm_table_name(physical_object.format)}" << 
			"WHERE physical_objects.id=technical_metadata.physical_object_id " << 
			"AND technical_metadata.as_technical_metadatum_id=tm_table_name(physical_object.format).id AND" <<
			physcial_object_where_clause(physical_object) 
	end

	private
	def Sql.tm_table_name(format)
		if format == "Open Reel Tape"
			"open_reel_tms"
		else
			raise "Unsupported format: #{format}"
		end
	end

	private
	def Sql.physcial_object_where_clause(po)
		sql = ""
		po.attributes.each do |name, value|
			if name == 'id' or name == 'created_at' or name == 'updated_at'
				next
			else
				if !value.nil? and value.length > 0
					operand = value.include? '*' ? ' like ' : '='
					v = value.include?('*') ? value.gsub(/[*]/, '%') : value
					sql << " AND physical_object.#{name}#{operand}'#{v}'"
				end
			end
		end
		sql
	end

	private
	def Sql.technical_metadata_where_claus(technical_metadatum)
		stm = technical_metadatum.specialize
		if stm.class == OpenReelTm.class
			Sql.open_reel_tm_where(technical_metadatum)
		else
			raise "Unsupported technical metadata class: #{technical_metadatum.class}"
		end
	end



	private 
	def Sql.open_reel_tm_where(specialized_technical_metadatum)
		q = ""
    stm.attributes.each do |name, value|
      #ignore these fields in the Sql WHERE clause
      if name == 'id' or name == 'created_at' or name == 'updated_at'
        next
      else
        if !value.nil? and value.length > 0
          q << " AND open_reel_tms.#{name}='#{value}'"
        end
      end
    end
    q
	end

end