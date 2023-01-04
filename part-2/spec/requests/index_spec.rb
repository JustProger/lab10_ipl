# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Index', type: :request do
  # создаем случайные значения
  let(:number) do
    10
  end
  let(:array) do
    mas = []
    i = 1
    number.times do
      mas << if i <= (number / 2)
               (Faker::Number.number(digits: 1)**2)
             else
               Faker::Number.within(range: 50..60)
             end
      i += 1
    end
    mas.join(' ')
  end

  # Тестируем корневой маршрут
  describe 'GET /' do
    before { get root_path } # перед каждым тестом делать запрос

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'renders input template' do
      expect(response).to render_template(:input)
    end

    it 'responds with html' do
      expect(response.content_type).to match(%r{text/html})
    end
  end

  # Тестируем маршрут вывода результата
  describe 'GET /index/output' do
    # Сценарий, когда параметры неправильные
    context 'when params are invalid (code = -2)' do
      # везде render_format: :xml, среди других возможных значений: :rss
      before { get "#{index_output_path}?#{URI.encode_www_form({ number: number + 1, array: array, render_format: :xml })}" }

      it 'returns http 302' do
        expect(response).to have_http_status(302)
      end

      it 'responds with html' do
        expect(response.content_type).to match(%r{text/html})
      end

      it 'assigns invalid controller instance variable' do
        expect(@controller.view_assigns['code']).to be(-2)
      end
    end

    context 'when params are invalid (code = -3)' do
      before { get "#{index_output_path}?#{URI.encode_www_form({ number: number, array: array, render_format: :some_format })}" }

      it 'returns http 302' do
        expect(response).to have_http_status(302)
      end

      it 'responds with html' do
        expect(response.content_type).to match(%r{text/html})
      end

      it 'assigns invalid controller instance variable' do
        expect(@controller.view_assigns['code']).to be(-3)
      end
    end

    # Сценарий, когда парамаетры правильные
    context 'when params are ok' do
      # перед каждым тестом делать запрос (params - параметры запроса, xhr: true - выполнить асинхронно, чтобы работал turbo)
      before { get "#{index_output_path}?#{URI.encode_www_form({ number: number, array: array, render_format: :xml })}" }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'responds with html' do
        expect(response.content_type).to match(%r{text/html})
      end

      it 'assigns invalid controller instance variable' do
        expect(@controller.view_assigns['code']).to be(0)
      end
    end
  end

  # Тестируем маршрут (формат .xml) вывода результата
  describe 'GET /index/output.xml' do
    # Сценарий, когда параметры неправильные
    context 'when params are invalid (code = -2)' do
      # везде render_format: :xml, среди других возможных значений: :rss
      before { get "#{index_output_path}?#{URI.encode_www_form({ number: number + 1, array: array, render_format: :xml })}" }

      it 'returns http 302' do
        expect(response).to have_http_status(302)
      end

      it 'responds with html' do
        expect(response.content_type).to match(%r{text/html})
      end

      it 'assigns invalid controller instance variable' do
        expect(@controller.view_assigns['code']).to be(-2)
      end
    end

    context 'when params are invalid (code = -3)' do
      before { get "#{index_output_path}?#{URI.encode_www_form({ number: number, array: array, render_format: :some_format })}" }

      it 'returns http 302' do
        expect(response).to have_http_status(302)
      end

      it 'responds with html' do
        expect(response.content_type).to match(%r{text/html})
      end

      it 'assigns invalid controller instance variable' do
        expect(@controller.view_assigns['code']).to be(-3)
      end
    end

    # Сценарий, когда парамаетры правильные
    context 'when params are ok' do
      # перед каждым тестом делать запрос (params - параметры запроса, xhr: true - выполнить асинхронно, чтобы работал turbo)
      before { get "#{index_output_path}?#{URI.encode_www_form({ number: number, array: array, render_format: :xml })}" }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'responds with html' do
        expect(response.content_type).to match(%r{text/html})
      end

      it 'assigns invalid controller instance variable' do
        expect(@controller.view_assigns['code']).to be(0)
      end
    end
  end
end
