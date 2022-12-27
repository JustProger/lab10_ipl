# frozen_string_literal: true

# IndexController class is a controller class for index
class IndexController < ApplicationController
  def output
    array = params[:array].split.map(&:to_i)
    number = params[:number].to_i

    if number == array.size
      enum = array.slice_when do |before, after|
        before_mod = is_square?(before)
        after_mod = is_square?(after)
        (!before_mod && after_mod) || (before_mod && !after_mod)
      end
    else
      # redirect_to(root_path,
      # notice: [-2, 'Количество элементов массива не совпадает с тем, что была введено!!!', nil, nil])
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
      format.xml { render xml: result }
      format.rss { render xml: result }
    end
  end

  private

  def is_square?(x)
    (Math.sqrt(x) % 1).zero?
  end
end
