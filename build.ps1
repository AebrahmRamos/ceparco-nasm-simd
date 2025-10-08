param(
    [switch]$Run,
    [int]$N = 256,
    [switch]$Clean
)

$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $here

function Abort([string]$msg) { Write-Error $msg; exit 1 }

if ($Clean) {
    Write-Host "Cleaning build artifacts..."
    Remove-Item -ErrorAction SilentlyContinue *.o, *.exe
    exit 0
}

# tools
$nasm = (Get-Command nasm -ErrorAction SilentlyContinue)
$gcc  = (Get-Command gcc  -ErrorAction SilentlyContinue)

if (-not $nasm) { Abort "nasm not found in PATH." }
if (-not $gcc)  { Abort "gcc not found in PATH." }

$asmFiles = @("NonVec.asm","asm_xmm.asm","asm_ymm.asm")
foreach ($f in $asmFiles) {
    if (-not (Test-Path $f)) { Abort "Missing assembly file: $f" }
}

$cFiles = @("main.c","c_kernel.c","kernel.h")
foreach ($f in $cFiles) {
    if (-not (Test-Path $f)) { Write-Warning "Missing C source/header: $f (continue if intentional)" }
}

# assemble
Write-Host "Assembling..."
foreach ($f in $asmFiles) {
    $obj = [IO.Path]::ChangeExtension($f, ".o")
    Write-Host "  nasm -f win64 -o $obj $f"
    & nasm -f win64 -o $obj $f
    if ($LASTEXITCODE -ne 0) { Abort "nasm failed on $f" }
}

# compile + link
Write-Host "Compiling and linking..."
$objs = @("NonVec.o","asm_xmm.o","asm_ymm.o")
$existingObjs = $objs | Where-Object { Test-Path $_ } 
$ccArgs = @("-O","-std=c17","-o","simd.exe","main.c","c_kernel.c") + $existingObjs
Write-Host "  gcc $($ccArgs -join ' ')"
& gcc @ccArgs
if ($LASTEXITCODE -ne 0) { Abort "gcc/link failed." }

Write-Host "Build succeeded: simd.exe"

if ($Run) {
    Write-Host "Running simd.exe with n=$N ..."
    & .\simd.exe $N
    exit $LASTEXITCODE
}