# frozen_string_literal: true

class Page < ApplicationRecord
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :language, inclusion: { in: %w[en fa] }
  
  before_validation :generate_slug, if: :title_changed?
  
  scope :published, -> { where(published: true) }
  scope :by_language, ->(lang) { where(language: lang) }
  
  def to_param
    slug
  end
  
  def rtl?
    Rails::Page::Builder.configuration.rtl_language?(language)
  end
  
  def render_content
    return '' if content.blank?
    
    content.html_safe
  end
  
  def full_css
    base_css = rtl? ? rtl_base_css : ltr_base_css
    custom_css = css.present? ? css : ''
    
    "#{base_css}\n#{custom_css}"
  end
  
  private
  
  def generate_slug
    return if title.blank?
    
    base_slug = title.parameterize
    counter = 1
    new_slug = base_slug
    
    while Page.where(slug: new_slug).where.not(id: id).exists?
      new_slug = "#{base_slug}-#{counter}"
      counter += 1
    end
    
    self.slug = new_slug
  end
  
  def ltr_base_css
    <<~CSS
      .page-content {
        direction: ltr;
        text-align: left;
      }
      .page-content img {
        max-width: 100%;
        height: auto;
      }
    CSS
  end
  
  def rtl_base_css
    <<~CSS
      .page-content {
        direction: rtl;
        text-align: right;
      }
      .page-content img {
        max-width: 100%;
        height: auto;
      }
    CSS
  end
end