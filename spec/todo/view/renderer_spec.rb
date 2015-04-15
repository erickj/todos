require 'todo/view/renderer'

RSpec.describe Todo::View::Renderer, :view do

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

  let(:render_block) { lambda { |tpl_name, mode, is_partial| template_data[tpl_name][mode] }}

  context 'given a layout name' do

    subject do
      Class.new do
        include Todo::View::Renderer
        view_layout :layout
      end.new
    end

    it 'renders the partial inside the layout' do
      rendered_str = subject.render :partial, :mode_foo, locals, &render_block
      expect(rendered_str).to be == 'Renderer Layout: Renderer Partial, local-x'
    end
  end
end
