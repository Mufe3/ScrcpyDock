Add-Type -AssemblyName System.Drawing

function Create-TrueColorIco {
    param(
        [string]$InputPng,
        [string]$OutputIco,
        [int[]]$Sizes = @(256, 128, 64, 48, 32, 16)
    )

    $srcBmp = [System.Drawing.Bitmap]::FromFile($InputPng)
    $dibBlocks = [System.Collections.Generic.List[byte[]]]::new()
    $sizesList = [System.Collections.Generic.List[int]]::new()

    foreach ($size in $Sizes) {
        $resized = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $g = [System.Drawing.Graphics]::FromImage($resized)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        # Preserve natural aspect ratio and center on transparent square canvas
        $scale = [Math]::Min($size / [double]$srcBmp.Width, $size / [double]$srcBmp.Height)
        $destWidth = [int][Math]::Round($srcBmp.Width * $scale)
        $destHeight = [int][Math]::Round($srcBmp.Height * $scale)
        $destX = [int][Math]::Round(($size - $destWidth) / 2.0)
        $destY = [int][Math]::Round(($size - $destHeight) / 2.0)

        $g.Clear([System.Drawing.Color]::Transparent)
        $g.DrawImage($srcBmp, $destX, $destY, $destWidth, $destHeight)
        $g.Dispose()

        # Build 32-bit ARGB DIB for ICO:
        # Header (40 bytes) + XOR data (size * size * 4) + AND mask (andRowBytes * size)
        $andRowBytes = [int]([Math]::Ceiling($size / 32.0) * 4)
        $andMaskSize = $andRowBytes * $size
        $xorSize = $size * $size * 4
        $totalDibSize = 40 + $xorSize + $andMaskSize

        $ms = New-Object System.IO.MemoryStream($totalDibSize)
        $w = New-Object System.IO.BinaryWriter($ms)

        # BITMAPINFOHEADER (40 bytes)
        $w.Write([uint32]40)              # biSize
        $w.Write([int32]$size)            # biWidth
        $w.Write([int32]($size * 2))      # biHeight (doubled for XOR + AND in ICO)
        $w.Write([uint16]1)               # biPlanes
        $w.Write([uint16]32)              # biBitCount
        $w.Write([uint32]0)               # biCompression = BI_RGB
        $w.Write([uint32]$xorSize)        # biSizeImage
        $w.Write([int32]0)                # biXPelsPerMeter
        $w.Write([int32]0)                # biYPelsPerMeter
        $w.Write([uint32]0)               # biClrUsed
        $w.Write([uint32]0)               # biClrImportant

        # Lock Bits for raw 32bppArgb (BGRA in memory on Windows)
        $rect = New-Object System.Drawing.Rectangle(0, 0, $size, $size)
        $bmpData = $resized.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $scan0 = $bmpData.Scan0
        $stride = $bmpData.Stride

        # DIBs are bottom-up: write rows from height - 1 down to 0
        $rowBuffer = New-Object byte[] ($size * 4)
        for ($y = $size - 1; $y -ge 0; $y--) {
            $rowPtr = [IntPtr]::new($scan0.ToInt64() + ($y * $stride))
            [System.Runtime.InteropServices.Marshal]::Copy($rowPtr, $rowBuffer, 0, $size * 4)
            $w.Write($rowBuffer)
        }
        $resized.UnlockBits($bmpData)
        $resized.Dispose()

        # In 32-bit ARGB icons, the alpha channel handles transparency.
        # AND mask is 0-filled.
        $andMask = New-Object byte[] $andMaskSize
        $w.Write($andMask)

        $w.Flush()
        $dibBytes = $ms.ToArray()
        $w.Close()
        $ms.Dispose()

        $dibBlocks.Add($dibBytes)
        $sizesList.Add($size)
    }
    $srcBmp.Dispose()

    # Now assemble the final .ICO file
    $fileStream = [System.IO.File]::Create($OutputIco)
    $icoWriter = New-Object System.IO.BinaryWriter($fileStream)

    # 1. ICONDIR (6 bytes)
    $icoWriter.Write([uint16]0)                  # Reserved
    $icoWriter.Write([uint16]1)                  # 1 = Icon
    $icoWriter.Write([uint16]$dibBlocks.Count)   # Image count

    $offset = 6 + (16 * $dibBlocks.Count)

    # 2. ICONDIRENTRY array (16 bytes each)
    for ($i = 0; $i -lt $dibBlocks.Count; $i++) {
        $s = $sizesList[$i]
        $len = $dibBlocks[$i].Length

        $dimW = if ($s -ge 256) { [byte]0 } else { [byte]$s }
        $dimH = if ($s -ge 256) { [byte]0 } else { [byte]$s }

        $icoWriter.Write([byte]$dimW)
        $icoWriter.Write([byte]$dimH)
        $icoWriter.Write([byte]0)                # ColorCount
        $icoWriter.Write([byte]0)                # Reserved
        $icoWriter.Write([uint16]1)              # Color planes
        $icoWriter.Write([uint16]32)             # Bits per pixel (32-bit true color)
        $icoWriter.Write([uint32]$len)           # Size of DIB
        $icoWriter.Write([uint32]$offset)        # Offset in file

        $offset += $len
    }

    # 3. DIB data blocks
    for ($i = 0; $i -lt $dibBlocks.Count; $i++) {
        $icoWriter.Write($dibBlocks[$i])
    }

    $icoWriter.Flush()
    $icoWriter.Close()
    $fileStream.Close()

    Write-Output "Successfully generated TRUE-COLOR 32-bit ICO: $OutputIco"
}

$pngPath = (Resolve-Path "assets\icon.png").Path
$ico1 = (Resolve-Path "assets\app_icon.ico").Path
$ico2 = (Resolve-Path "windows\runner\resources\app_icon.ico").Path

Create-TrueColorIco -InputPng $pngPath -OutputIco $ico1
Create-TrueColorIco -InputPng $pngPath -OutputIco $ico2
