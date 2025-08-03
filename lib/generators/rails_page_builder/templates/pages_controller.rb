# frozen_string_literal: true

module PageBuilder
  class PagesController < ApplicationController
    before_action :set_page, only: [:show, :edit, :update, :destroy]
    protect_from_forgery except: [:create, :update]
    
    def index
      @pages = Page.all.order(updated_at: :desc)
    end
    
    def show
      respond_to do |format|
        format.html
        format.json { render json: page_data }
      end
    end
    
    def new
      @page = Page.new
    end
    
    def create
      @page = Page.new(page_params)
      
      if @page.save
        respond_to do |format|
          format.html { redirect_to edit_page_builder_page_path(@page), notice: 'Page created successfully.' }
          format.json { render json: page_data, status: :created }
        end
      else
        respond_to do |format|
          format.html { render :new }
          format.json { render json: @page.errors, status: :unprocessable_entity }
        end
      end
    end
    
    def edit
    end
    
    def update
      if @page.update(page_params)
        respond_to do |format|
          format.html { redirect_to @page, notice: 'Page updated successfully.' }
          format.json { render json: page_data }
        end
      else
        respond_to do |format|
          format.html { render :edit }
          format.json { render json: @page.errors, status: :unprocessable_entity }
        end
      end
    end
    
    def destroy
      @page.destroy
      respond_to do |format|
        format.html { redirect_to page_builder_pages_path, notice: 'Page deleted successfully.' }
        format.json { head :no_content }
      end
    end
    
    private
    
    def set_page
      @page = Page.find(params[:id])
    end
    
    def page_params
      params.require(:page).permit(:title, :slug, :content, :css, :metadata, :language, :published)
    end
    
    def page_data
      {
        id: @page.id,
        title: @page.title,
        slug: @page.slug,
        content: @page.content,
        css: @page.css,
        metadata: @page.metadata,
        language: @page.language,
        published: @page.published
      }
    end
  end
end