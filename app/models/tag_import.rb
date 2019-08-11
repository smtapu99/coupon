class TagImport < ApplicationRecord
  include ActsAsImportable

  belongs_to :site
  validates_presence_of :site_id

  def run
    @error_messages = []

    if import_tags
      update_attribute(:status, 'done')
      return true
    end

    update_attributes(error_messages: @error_messages, status: 'error')
    return false
  end

  def self.grid_filter(params)
    query = self
    query = query.where(site_id: params[:site_id]) if params[:site_id].present?
    query = query.where(id: params[:id]) if params[:id].present?
    query = query.where('word like ?', "%#{params[:word]}%") if params[:word].present?

    query
  end

  private

  def import_tags
    spreadsheet = open_spreadsheet
    header = spreadsheet.row(1)

    Tag.transaction do
      (2..spreadsheet.last_row).map do |i|
        invalid_category = false
        row = Hash[[header, spreadsheet.row(i)].transpose]

        if row['Tag ID'].present?
          tag = Tag.find_by(id: row['Tag ID'])
        else
          tag = Tag.find_or_initialize_by(
            site_id: site.id,
            word: row['Word'].to_s.strip
          )
        end

        cols = row.to_hash.slice(*Tag::allowed_import_params)

        if cols['Word'].present?
          if tag.new_record?
            tag.word = cols['Word'].to_s.strip
          else
            tag.word = cols['Word']
          end
        end

        if cols['Is Blacklisted'].present?
          tag.is_blacklisted = cols['Is Blacklisted'] == 'yes' ? 1 : 0
        end

        if cols['Category Slug'].present?
          begin
            tag.category = Category.active.find_by!(site_id: site.id, slug: cols['Category Slug'].to_s.downcase.strip)
          rescue Exception => e
            invalid_category = true
          end
        else
          tag.category = nil
        end

        if tag.valid? && !invalid_category
          tag.save!
        else
          tag.errors.full_messages.each do |message|
            @error_messages << "Row #{i}: #{message}"
          end
          @error_messages << "Row #{i}: Cannot find Category with slug '#{cols['Category Slug']}'" if invalid_category
        end
      end

      if @error_messages.present?
        ActiveRecord::Rollback
        return false
      end
    end

    true
  end
end
