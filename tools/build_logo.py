"""Draw the original project listing mark; no game artwork or font is used."""
from pathlib import Path
from PIL import Image, ImageDraw

out = Path('assets'); out.mkdir(exist_ok=True)
scale = 3
im = Image.new('RGB', (512 * scale, 512 * scale), '#18242a')
d = ImageDraw.Draw(im)
polygons = [
    ([(88, 204), (254, 134), (424, 204), (258, 276)], '#c99b60'),
    ([(88, 204), (258, 276), (258, 432), (88, 360)], '#8c5836'),
    ([(258, 276), (424, 204), (424, 360), (258, 432)], '#af7645'),
    ([(122, 191), (290, 261), (319, 249), (151, 179)], '#334349'),
    ([(290, 261), (319, 249), (319, 406), (290, 418)], '#28363b'),
    ([(192, 160), (361, 231), (391, 218), (222, 148)], '#334349'),
    ([(361, 231), (391, 218), (391, 374), (361, 387)], '#28363b'),
    ([(88, 240), (258, 312), (258, 335), (88, 263)], '#c28b53'),
    ([(88, 315), (258, 387), (258, 410), (88, 338)], '#c28b53'),
]
for points, color in polygons:
    d.polygon([(x * scale, y * scale) for x, y in points], fill=color)
for y in [224, 350]:
    d.ellipse((101*scale, y*scale, 110*scale, (y+9)*scale), fill='#e0b779')
d.ellipse((312*scale, 310*scale, 460*scale, 458*scale), fill='#172329')
d.ellipse((320*scale, 318*scale, 452*scale, 450*scale), fill='#e6bd64')
d.ellipse((330*scale, 328*scale, 442*scale, 440*scale), fill='#9b662f')
d.ellipse((336*scale, 334*scale, 436*scale, 434*scale), fill='#e6bd64')
d.polygon([(386*scale, 353*scale), (411*scale, 384*scale), (386*scale, 415*scale), (361*scale, 384*scale)], fill='#76502d')
im.resize((512, 512), Image.Resampling.LANCZOS).save(out/'waylaid-value-512.png')
print('Created original 512px crate-and-Favor listing mark.')
