require 'rspec'
require_relative '../../lib/ju' 

describe Ju::LayoutPacker do
  it 'should pack the given widget to the first row' do
    widgets = [
     { 'name' => 'widget1', 'row' => 1, 'col' => '1', 'sizex' => 1, 'sizey' => 1 },
     { 'name' => 'widget2', 'row' => 2, 'col' => '1', 'sizex' => 3, 'sizey' => 2 },
     { 'name' => 'widget3', 'row' => 4, 'col' => '1', 'sizex' => 1, 'sizey' => 1 },
     { 'name' => 'widget4'},
     { 'name' => 'widget5'}
    ]
    Ju::LayoutPacker.pack(widgets)
    widget4 = widgets.find{ |w| w['name'] == 'widget4' }
    expect(widget4['row']).to eq(1)
    expect(widget4['col']).to eq(2)
    expect(widget4['sizex']).to eq(1)
    expect(widget4['sizey']).to eq(1)
    widget5 = widgets.find{ |w| w['name'] == 'widget5' }
    expect(widget5['row']).to eq(1)
    expect(widget5['col']).to eq(3)
    expect(widget5['sizex']).to eq(1)
    expect(widget5['sizey']).to eq(1)
  end

  it 'should pack the given widget to next row' do
    widgets = [
     { 'name' => 'widget1', 'row' => 1, 'col' => '1', 'sizex' => 1, 'sizey' => 1 },
     { 'name' => 'widget2', 'row' => 1, 'col' => '3', 'sizex' => 1, 'sizey' => 2 },
     { 'name' => 'widget3', 'row' => 4, 'col' => '1', 'sizex' => 2, 'sizey' => 1 },
     { 'name' => 'widget'}
    ]
    Ju::LayoutPacker.pack widgets
    widget = widgets.find{ |w| w['name'] == 'widget' }
    expect(widget['row']).to eq(4)
    expect(widget['col']).to eq(3)
    expect(widget['sizex']).to eq(1)
    expect(widget['sizey']).to eq(1)
  end

  it 'should pack the given widget to the middle row' do
    widgets = [
     { 'name' => 'widget1', 'row' => 1, 'col' => '1', 'sizex' => 1, 'sizey' => 1 },
     { 'name' => 'widget2', 'row' => 1, 'col' => '2', 'sizex' => 2, 'sizey' => 1 },
     { 'name' => 'widget3', 'row' => 2, 'col' => '1', 'sizex' => 2, 'sizey' => 2 },
     { 'name' => 'widget4', 'row' => 4, 'col' => '1', 'sizex' => 1, 'sizey' => 1 },
     { 'name' => 'widget'}
    ]
    Ju::LayoutPacker.pack widgets
    widget = widgets.find{ |w| w['name'] == 'widget' }
    expect(widget['row']).to eq(2)
    expect(widget['col']).to eq(3)
    expect(widget['sizex']).to eq(1)
    expect(widget['sizey']).to eq(1)
  end
end
