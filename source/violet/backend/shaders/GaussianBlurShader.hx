package violet.backend.shaders;

import violet.backend.utils.FileUtil;

import flixel.addons.display.FlxRuntimeShader;

/**
 * Note... not actually gaussian!
 */
class GaussianBlurShader extends FlxRuntimeShader
{
  public var amount:Float = 1;

  public function new(amount:Float = 1.0)
  {
    super(FileUtil.getFileContent(Paths.frag("gaussianBlur")));
    setAmount(amount);
  }

  public function setAmount(value:Float):Void
  {
    this.amount = value;
    this.setFloat("_amount", amount);
  }
}