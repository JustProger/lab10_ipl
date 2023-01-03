# frozen_string_literal: true

# IndexController class is a controller class for index
class IndexController < ApplicationController
  def output
    array = params[:array].split.map(&:to_i)
    number = params[:number].to_i

    enum = array.slice_when do |before, after|
      before_mod = is_square?(before)
      after_mod = is_square?(after)
      (!before_mod && after_mod) || (before_mod && !after_mod)
    end

    @sequences = enum.to_a.select { |array| array.any? { |element| is_square?(element) } }
    @maxsequence = @sequences.max_by(&:size)
    @sequences_number = @sequences.size

    result = [
      {
        title: 'Последовательности',
        value: @sequences.to_s
      },
      {
        title: 'Максимальная последовательность',
        value: @maxsequence.to_s
      },
      {
        title: 'Количество последовательностей',
        value: @sequences_number.to_s
      }
    ]

    respond_to do |format|
      format.xml { render xml: render_xml(result) }
      format.rss { render xml: render_rss(result) }
    end
  end

  private

  def render_xml(result)
    p 'render_xml'
    result
  end

  def render_rss(result)
    p 'render_rss'
    result
  end

  def is_square?(x)
    (Math.sqrt(x) % 1).zero?
  end
end
