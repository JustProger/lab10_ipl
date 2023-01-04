# frozen_string_literal: true

require 'net/http'

XML_SERVER = 'http://localhost:3000/?' # если не указан формат, то в контроллере index 1го приложения по умолчанию отрендерится xml формат
RSS_SERVER = 'http://localhost:3000/index/output.rss?' # здесь надо указать формат явно, т. к. это не xml (который по умолчанию)
XSL_LINK = "\n<?xml-stylesheet href=\"/visualizer.xslt\" type=\"text/xsl\"?>"
XSLT = Nokogiri::XSLT(File.read('public/visualizer.xslt'))

class IndexController < ApplicationController
  before_action :check_and_set_input_data, only: :output

  def input; end

  def output
    xml = get_xml(params[:array], params[:number], params[:render_format]).body
    respond_to do |format|
      # хоть и указаны разные форматы xml и html, в итоге клиент видит html
      # рендеринг xml происходит у клиента по xslt шаблону, переданному через строку XSL_LINK
      format.xml { render xml: render_client(xml) }
      format.html { render html: render_server(xml) } # рендерениг происходит на сервере при помощи Nokogiri
    end
  end

  private

  def get_xml(array, number, render_format)
    case render_format
    when 'xml'
      uri = URI(XML_SERVER)
    when 'rss'
      uri = URI(RSS_SERVER)
    end
    uri.query = URI.encode_www_form({ array: array, number: number })
    p '-------------- get_xml method ---------------'
    p URI.encode_www_form({ array: array, number: number })
    p uri
    p uri.class
    p '-------------------- end --------------------'
    Net::HTTP.get_response(uri)
  end

  def render_client(xml)
    result = xml.insert(xml.index("\n"), XSL_LINK)
    p '----------- render_client method ------------'
    p xml.class
    p result
    p '-------------------- end --------------------'
    result
  end

  def render_server(xml)
    p '----------- render_server method ------------'
    p XSLT
    p '-------------------- end --------------------'
    XSLT.transform(Nokogiri::XML(xml))
        .to_s
        .html_safe # Marks a string as trusted safe. It will be inserted into HTML with no additional escaping performed.
  end

  def check_and_set_input_data
    # инициализация некоторых переменных (считаем, что программа работает без ошибки)
    @code = 0
    @err_msg = nil
    @ind_of_err_sym = nil

    return unless check_str(params[:array])
    return unless check_str(params[:number])
    return unless check_render_format(params[:render_format])
    return unless check_equality_of_array_size_and_number(params[:array], params[:number])
  end

  # Из-за ошибки при составлении тестов rspec:
  #   AbstractController::DoubleRenderError:
  #   Render and/or redirect were called multiple times in this action. ...
  # был вынужден ввести такую систему:
  #   Возвращаем true, если ошибки нет
  #   Иначе возвращаем nil

  def check_equality_of_array_size_and_number(array, number)
    unless array.split(' ').size == number.to_i
      @code = -2
      redirect_to(root_path,
                  notice: [@code, 'Количество элементов массива не совпадает с тем, что была введено!!!', nil, nil])
      return
    end
    true
  end

  def check_render_format(render_format_to_check)
    # проверка последнего параметра params[:render_format]
    unless %w[xml rss].include? render_format_to_check
      @code = -3
      redirect_to(root_path,
                  notice: [@code = -3, 'Неизвестный формат рендеринга (должно быть одно из двух: XML, RSS)!', nil, nil])
      return
    end
    true
  end

  # проверка: строка должно состоять из натуральных чисел
  def check_str(str_to_check)
    return true if str_to_check.is_a?(String) && str_to_check.match?(/^[\d ]+$/) && str_to_check.match?(/\d/)

    check_str_all(str_to_check) # check_str_all - для поиска ошибки, т. е. ошибка есть, тогда возвращаем nil из метода check_str
    nil
  end

  def check_str_all(str_to_check)
    ptrn_list = [
      /[[:alpha:]]/,
      /[[:punct:]]/
    ]
    error_messages = [
      'Без букв!',
      'Без знаков пунктуации!'
    ]

    # Пояснение.
    # Код ошибки code:
    #   -2 --- количество элементов массива не совпадает с тем, что была введено (!!!проверка осуществляется в методе show)
    #   -1 --- неизвестная ошибка
    #   [значение > 0] --- остальные ошибки с пояснениями (индекс из массива error_messages + 1)

    # другие параметры:
    # ind_of_err_sym --- индекс символа в строке str_to_check, который мог вызвать ошибку

    if (err_ind = ptrn_list.find_index { |ptrn| @ind_of_err_sym = ptrn.match(str_to_check) })
      @code = err_ind + 1
      @err_msg = error_messages[err_ind]
      @ind_of_err_sym = @ind_of_err_sym.to_s
    else
      @code = -1
      @err_msg = 'Неизвестная ошибка! :( сам разбирайся... :('
      @ind_of_err_sym = nil
    end

    return if @code.zero?

    redirect_to(root_path, notice: [@code, @err_msg, @ind_of_err_sym, str_to_check])
  end
end
