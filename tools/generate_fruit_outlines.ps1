Add-Type -AssemblyName System.Drawing

$fruitRoot = Join-Path $PSScriptRoot '..\assets\images\fruits'
$outlinedRoot = Join-Path $fruitRoot 'outlined'
$closedRoot = Join-Path $fruitRoot 'close'
$fruitColors = @(
  '#E97867', '#B978A5', '#F1C45F', '#91B86A', '#F1A078', '#70A984',
  '#DA6B5B', '#6E9FC7', '#DBA94B', '#8D79B8', '#5D9B91'
)
$borderWidth = 10
$canvasSize = 512
$renderScale = 4
$renderSize = $canvasSize * $renderScale
$renderBorderWidth = $borderWidth * $renderScale
$borderInset = $renderBorderWidth / 2
$ellipseSize = $renderSize - $renderBorderWidth

foreach ($index in 1..11) {
  $fileName = 'fruit{0:D2}.png' -f $index
  $borderColor = [System.Drawing.ColorTranslator]::FromHtml($fruitColors[$index - 1])

  foreach ($sourceDirectory in @($fruitRoot, $closedRoot)) {
    $sourcePath = Join-Path $sourceDirectory $fileName
    $destinationDirectory = if ($sourceDirectory -eq $closedRoot) {
      Join-Path $outlinedRoot 'close'
    } else {
      $outlinedRoot
    }
    $source = [System.Drawing.Bitmap]::new($sourcePath)
    $rendered = [System.Drawing.Bitmap]::new(
      $renderSize,
      $renderSize,
      [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
    )
    $graphics = [System.Drawing.Graphics]::FromImage($rendered)
    $pen = [System.Drawing.Pen]::new($borderColor, $renderBorderWidth)
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $output = [System.Drawing.Bitmap]::new(
      $canvasSize,
      $canvasSize,
      [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
    )
    $outputGraphics = [System.Drawing.Graphics]::FromImage($output)

    try {
      $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
      $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
      $graphics.Clear([System.Drawing.Color]::Transparent)
      $path.AddEllipse($borderInset, $borderInset, $ellipseSize, $ellipseSize)
      $graphics.SetClip($path)
      $graphics.DrawImage($source, 0, 0, $renderSize, $renderSize)
      $graphics.ResetClip()
      $graphics.DrawEllipse(
        $pen,
        $borderInset,
        $borderInset,
        $ellipseSize,
        $ellipseSize
      )

      $outputGraphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
      $outputGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
      $outputGraphics.DrawImage($rendered, 0, 0, $canvasSize, $canvasSize)
      $output.Save(
        (Join-Path $destinationDirectory $fileName),
        [System.Drawing.Imaging.ImageFormat]::Png
      )
    } finally {
      $pen.Dispose()
      $path.Dispose()
      $graphics.Dispose()
      $outputGraphics.Dispose()
      $rendered.Dispose()
      $output.Dispose()
      $source.Dispose()
    }
  }
}