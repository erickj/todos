RSpec.describe Todo::View::RenderableView, :view do

  let(:template_data) do
    {
      :layout => {
        :txt => 'Hello from Layout! <%= yield %>',
        :html => '<h1>Hello from Layout! <%= yield %></h1>'
      },
      :partial =>  {
        :txt => 'Hello from Partial?',
        :html => '<em>Hello from Partial?</em>'
      }
    }
  end

  let(:locals) do
    {
      :local_time => Time.now,
      :a_string => 'a local value'
    }
  end

  let(:globals) do
    {
      :global_time => Time.now.utc,
      :string => 'a global value'
    }
  end

  subject do
    Todo::View::RenderableView.new :partial, globals, :layout do |tpl_name, mode, is_partial|
      template_data[tpl_name][mode]
    end
  end

  context 'layout with partial' do
    it 'renders in :txt mode' do
      rendered_view = subject.render :txt
      expect(rendered_view).to be == 'Hello from Layout! Hello from Partial?'
    end

    it 'renders in :html mode' do
      rendered_view = subject.render :html
      expect(rendered_view).to be == '<h1>Hello from Layout! <em>Hello from Partial?</em></h1>'
    end

    it 'renders in :whatever mode' do
      template_data[:layout][:whatever] = 'Whatever? <%= yield %>'
      template_data[:partial][:whatever] = 'Whatever!'

      rendered_view = subject.render :whatever
      expect(rendered_view).to be == 'Whatever? Whatever!'
    end
  end

  context 'local data' do
    it 'is accessible to the partial' do
      template_data[:partial][:txt] =
        'Local values: <%= locals.local_time.to_i %>, <%= locals.a_string %>'

      rendered_view = subject.render :txt, locals

      expected_str = 'Hello from Layout! Local values: %s, %s' % [locals[:local_time].to_i, locals[:a_string]]
      expect(rendered_view).to be == expected_str
    end

    it 'is inaccessible to the layout'do
      template_data[:layout][:txt] =
        'Local values: <%= locals.local_time.to_i %>, <%= locals.a_string %>'

      expect { subject.render :txt, locals }.to raise_error
    end
  end

  context 'global data' do
    it 'is accessible to the partial' do
      template_data[:partial][:txt] =
        'Global values: <%= globals.global_time.to_i %>, <%= globals.a_string %>'

      rendered_view = subject.render :txt

      expected_str = 'Hello from Layout! Global values: %s, %s' % [globals[:global_time].to_i, globals[:a_string]]
      expect(rendered_view).to be == expected_str
    end

    it 'is accessible to the layout'do
      template_data[:layout][:txt] =
        'Global values: <%= globals.global_time.to_i %>, <%= globals.a_string %>'

      rendered_view = subject.render :txt

      expected_str = 'Global values: %s, %s' % [globals[:global_time].to_i, globals[:a_string]]
      expect(rendered_view).to be == expected_str
    end
  end

  context 'rendering partials from templates' do
    it 'should pass partial locals' do
      template_data[:layout][:txt] =
        'With a custom partial: <%= render_partial :my_partial, { :partial_data => "Zow-Wee!"} %>'
      template_data[:my_partial] = {
        :txt =>  'My partial! <%= locals.partial_data %>'
      }

      expect(subject.render :txt).to be == 'With a custom partial: My partial! Zow-Wee!'
    end
  end

  context 'template files' do

    let(:tpls) do
      {
        :layouts => { :'file_layout' => { :txt => 'My txt file layout! <%= yield %>' }},
        :partials => { :'file_partial' => { :txt => 'My txt file partial!' }}
      }
    end

    subject { Todo::View::RenderableView.new :file_partial, globals, :file_layout }

    it 'should be looked up by name and mode' do
      run_with_template_files tpls[:layouts], tpls[:partials] do
        expect(subject.render :txt).to be == 'My txt file layout! My txt file partial!'
      end
    end
  end

  context 'missing template file' do

    subject { Todo::View::RenderableView.new :missing_partial, {}, {}, :file_layout }

    it 'should raise an error' do
      expect { subject.render :txt}.to raise_error
    end
  end
end
