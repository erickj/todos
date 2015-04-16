require 'todo/view/renderer'

RSpec.describe Todo::View::Renderer, :view do

  it_behaves_like 'a string helper'

  let(:locals) {{ :x => 'local-x' }}

  let(:template_data) do
    {
      :layout => {
        :mode_foo => 'Renderer Layout: <%= yield %>',
      },
      :partial =>  {
        :mode_foo => 'Renderer Partial, <%= locals.x %>',
      }
    }
  end

  subject do
    Class.new do
      include Todo::View::Renderer
      view_layout :layout
    end.new
  end

  context 'given a render block' do
    let(:render_block) { lambda { |tpl_name, mode, is_partial| template_data[tpl_name][mode] }}

    it 'renders the partial inside the layout' do
      rendered_str = subject.render :partial, :mode_foo, locals, &render_block
      expect(rendered_str).to be == 'Renderer Layout: Renderer Partial, local-x'
    end
  end

  context 'given layout files' do

    let(:layouts) {{ :layout => template_data[:layout] } }
    let(:partials) {{ :partial => template_data[:partial] }}

    it 'renders the partial inside the layout' do
      run_with_template_files layouts, partials do
        rendered_str = subject.render :partial, :mode_foo, locals
        expect(rendered_str).to be == 'Renderer Layout: Renderer Partial, local-x'
      end
    end
  end
end
