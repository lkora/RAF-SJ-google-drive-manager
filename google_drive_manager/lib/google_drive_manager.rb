# frozen_string_literal: true

require_relative "google_drive_manager/version"
require "google_drive"

module GoogleDriveManager
  class Error < StandardError; end

  class Sheet
    include Enumerable

    def initialize(session, key, index)
      raise "Session is not initialized" if session.nil?
      @ws = session.spreadsheet_by_key(key).worksheets[index]
      @header = rows.first
    end
    
    def rows
      @ws.rows.reject { |row| row.any? { |cell| cell.downcase.include?("total") || cell.downcase.include?("subtotal") } }
    end
    

    def row(index)
      @ws.rows[index]
    end

    def each
      @ws.rows.flatten.each { |cell| yield cell }
    end

    def method_missing(name, *args, &block)
      column_name = name.to_s.split("_").map(&:capitalize).join(" ")
      if @header.include?(column_name)
        self[column_name]
      else
        super
      end
    end
    
    
    def [](column_name)
      column_index = @header.index(column_name) + 1
      raise Error.new("Column not found") unless column_index

      Column.new(@ws, column_index)
    end
    
    def +(other)
      raise Error.new("Headers do not match") unless @header == other.rows.first
    
      new_rows = rows[1..-1].zip(other.rows[1..-1]).map do |row1, row2|
        next [] if row2.nil?
    
        row1.map.with_index { |cell, i| cell.to_i + row2[i].to_i }
      end
    
      @ws.update_cells(1, 1, [@header] + new_rows)
      @ws.save
    
      self
    end   
    

    def -(other)
      raise Error.new("Headers do not match") unless rows.first == other.rows.first
    
      new_rows = rows[1..-1].zip(other.rows[1..-1]).map do |row1, row2|
        row1.map.with_index { |cell, i| cell.to_i - (row2.nil? ? 0 : row2[i].to_i) }
      end
    
      @ws.delete_rows(1, @ws.num_rows) 
      @ws.update_cells(1, 1, [@header] + new_rows)
      @ws.save
    
      self
    end    
        

    class Column
      def initialize(worksheet, index)
        @ws = worksheet
        @index = index
      end
      
      def to_a
        (1..@ws.num_rows).map { |row_index| self[row_index - 1] }
      end

      def map(&block)
        to_a.map(&block)
      end

      def select(&block)
        to_a.select(&block)
      end
    
      def reduce(initial = nil, &block)
        to_a.reduce(initial, &block)
      end

      def [](row_index)
        if row_index.is_a? Integer
          @ws[row_index + 1, @index]
        elsif row_index.is_a? String
          row_number = (1..@ws.num_rows).find { |i| @ws[i, @index] == row_index }
          row_number.nil? ? nil : row_number - 1
        else
          raise ArgumentError, "row_index must be an Integer or String. If row is Integer it will return the value stored at that row for the given column, if the row is a string it will find the row with that value and return it's number."
        end
      end

      def []=(row_index, value)
        @ws[row_index + 1, @index] = value
        @ws.save
      end

      def sum
        to_a.map(&:to_i).sum
      end

      def avg
        to_a.map(&:to_i).sum.to_f / @ws.num_rows
      end

      def method_missing(name, *args, &block)
        column_name = name.to_s.gsub('_', ' ').capitalize
        self[column_name] if @header.include?(column_name) || super
      end
              

      def each
        to_a.each { |cell| yield cell }
      end

    end
  end
end
