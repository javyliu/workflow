module ActiveRecordExtension
  extend ActiveSupport::Concern

  module ClassMethods
    #recood_list: [{a: 10,b:20,id: 200]}
    #codes: params[codes] =[{}{}]
    def import!(record_list)
      raise ArgumentError "record_list not an Array of Hashes" unless record_list.is_a?(Array) && record_list.all? {|rec| rec.is_a? Hash }
      return record_list if record_list.empty?

      (1..record_list.count).step(1000).each do |start|
        key_list, value_list = convert_record_list(record_list[start-1..start+999])
        sql = "INSERT INTO #{self.table_name} (#{key_list.join(", ")}) VALUES #{value_list.map {|rec| "(#{rec.join(", ")})" }.join(" ,")}"
        #Rails.logger.info sql
        self.connection.insert_sql(sql)
      end

      return record_list
    end

    def convert_record_list(record_list)
      # Build the list of keys
      #key_list = record_list.map(&:keys).flatten.map(&:to_s).uniq.sort
      key_list = record_list[0].symbolize_keys.keys

      #value_list = record_list.map do |rec|
      #  list = []
      #  key_list.each {|key| list <<  self.connection.quote(rec[key] || rec[key.to_sym]) }
      #  list
      #end

      value_list = record_list.inject([]) do |sum,item|
        sum << item.symbolize_keys.values_at(*key_list).map{|it| self.connection.quote(it)}
      end

      # If table has standard timestamps and they're not in the record list then add them to the record list
      time = self.connection.quote(Time.now)
      #for field_name in %w(created_at updated_at)
      #  if self.column_names.include?(field_name) && !(key_list.include?(field_name))
      #    key_list << field_name
      #    value_list.each {|rec| rec << time }
      #  end
      #end

      if (tc = self.column_names & %w(created_at updated_at)).present?
        tc.each do |c|
          unless key_list.include?(c)
            key_list << c
            value_list.each {|rec| rec << time }
          end
        end
      end

      return [key_list.map(&:to_s), value_list]
    end


  end


end

#ActiveRecord::Base.send(:include,ActiveRecordExtension)
