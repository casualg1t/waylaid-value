"""Original rounded UI primitives; no OneForAll artwork or code is included."""
from pathlib import Path
from PIL import Image, ImageDraw

target=Path('addon/WaylaidValue')
for name,outline in [('SkinFill',False),('SkinRing',True)]:
 image=Image.new('RGBA',(128,128))
 draw=ImageDraw.Draw(image)
 draw.rounded_rectangle((0,0,127,127),radius=16,fill=None if outline else 'white',outline='white'if outline else None,width=4)
 image.resize((32,32),Image.Resampling.LANCZOS).save(target/(name+'.tga'))
print('Generated original 4px-radius fill/ring skin primitives.')
