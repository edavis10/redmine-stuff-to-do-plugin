module StuffToDoHelper
  def progress_bar_sum(collection, field, opts)
    total = collection.inject(0) {|sum, n| sum + n.read_attribute(field) }
    divisor = collection.length
    return if divisor.nil? || divisor == 0

    progress_bar(total / divisor, opts)
  end
end
