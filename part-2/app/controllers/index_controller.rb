# frozen_string_literal: true

require 'net/http'

XML_SERVER = 'http://localhost:3000/?' # если не указан формат, то в контроллере index 1го приложения по умолчанию отрендерится xml формат
RSS_SERVER = 'http://localhost:3000/index/output.rss?' # здесь надо указать формат явно, т. к. это не xml (который по умолчанию)
XSL_LINK = "\n<?xml-stylesheet href=\"/visualizer.xslt\" type=\"text/xsl\"?>"
XSLT = Nokogiri::XSLT(File.read('public/visualizer.xslt'))

class IndexController < ApplicationController
  before_action :check_params, only: :output

  def input; end

  def output
    xml = get_xml(params[:array], params[:number], params[:render_format]).body
    respond_to do |format|
      # хоть и указаны разные форматы xml и html, в итоге клиент видит html
      # рендеринг xml происходит у клиента по xslt шаблону, переданному через строку XSL_LINK
      format.xml do
        render xml: render_client(xml)
      end
      format.html { render html: render_server(xml) } # рендерениг происходит на сервере при помощи Nokogiri
    end
  end

  private

  def check_params
    return if %w[xml rss].include? params[:render_format]

    redirect_to(root_path,
                notice: [-3, 'Неизвестный формат рендеринга (должно быть одно из двух: XML, RSS)!', nil, nil])
  end

  def get_xml(array, number, render_format)
    case render_format
    when 'xml'
      uri = URI(XML_SERVER)
    when 'rss'
      uri = URI(RSS_SERVER)
    end
    uri.query = URI.encode_www_form({ array:, number: })
    p '-------------- get_xml method ---------------'
    p URI.encode_www_form({ array:, number: })
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
end
