class PaginatingDecorator < Draper::CollectionDecorator
  # support for will_paginate
  delegate :current_page, :total_entries, :total_pages, :per_page, :offset,:limit_value,:last_page?,:offset_value,:total_count
  def set_total_count
    #raise '请提供block' unless blk
    #object.instance_variable_set(:@total_count,blk.call(object))
    raise 'no block' unless block_given?
    object.instance_variable_set(:@total_count,yield(object))
  end
  #delegate :limit_value if defined?(Kaminari)
end
