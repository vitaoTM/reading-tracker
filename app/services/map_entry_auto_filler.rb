class MapEntryAutoFiller
  def self.call(reading_entry) = new(reading_entry).call

  def initialize(reading_entry)
    @re = reading_entry
  end

  def call
    return unless @re.reading? || @re.finished?

    code = @re.book.country_of_origin&.strip&.upcase
    nil unless code&.match?(/\A[A-Z]{2}\z/)

    entry = @re.user.map_entries.find_or_initialize_by(country_code: code)
    if entry.new_record?
      entry.assign_attributes(
        color: MapEntry::STATUS_COLORS[@re.status],
        auto_filled: true,
        book_id: @re.book_id
      )
      entry.save
    elsif entry.auto_filled? && entry.book_id == @re.book_id
      entry.update(color: MapEntry::STATUS_COLORS[@re.status])
    end
  end
end
