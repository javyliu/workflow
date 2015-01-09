class PaginatingDecorator < Draper::CollectionDecorator
  # support for will_paginate
  delegate :current_page, :total_entries, :total_pages, :per_page, :offset,:limit_value,:total_count,:last_page?,:offset_value
  #delegate :limit_value if defined?(Kaminari)
end
