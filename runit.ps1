
function NpmBenchmark-Build {

    param (
        $cloneUrl,
        $dirName,
        $buildCommand
    )
    $cloneSw = New-Object System.Diagnostics.Stopwatch
    if ( -not (Test-Path -Path $dirName -PathType Container) )
    {
        $cloneSw.Start()
        git clone $cloneUrl
        $cloneSw.Stop()
    }

    pushd 
    cd $dirName
    $installSw1 = New-Object System.Diagnostics.Stopwatch
    $installSw1.Start()
    npm install
    $installSw1.Stop()

    $installSw2 = New-Object System.Diagnostics.Stopwatch
    $installSw2.Start()
    npm install
    $installSw2.Stop()

    $build1Sw = New-Object System.Diagnostics.Stopwatch
    $build1Sw.Start()
    npm run $buildCommand
    $build1Sw.Stop()

    $build2Sw = New-Object System.Diagnostics.Stopwatch
    $build2Sw.Start()
    npm run $buildCommand
    $build2Sw.Stop()

    popd

    return $cloneSw, $installSw1, $installSw2, $build1Sw, $build2Sw
}

function DotnetBenchmark-Build {

    param (
        $cloneUrl,
        $dirName,
        $buildCommand
    )
    $cloneSw = New-Object System.Diagnostics.Stopwatch
    if ( -not (Test-Path -Path $dirName -PathType Container) )
    {
        $cloneSw.Start()
        git clone $cloneUrl
        $cloneSw.Stop()
    }

    pushd 
    cd $dirName
    $installSw1 = New-Object System.Diagnostics.Stopwatch
    $installSw1.Start()
    Write-Host "dotnet restore $dirName"
    dotnet restore
    $installSw1.Stop()

    $installSw2 = New-Object System.Diagnostics.Stopwatch
    $installSw2.Start()
    Write-Host "dotnet restore $dirName"
    dotnet restore
    $installSw2.Stop()

    $build1Sw = New-Object System.Diagnostics.Stopwatch
    $build1Sw.Start()
    Write-Host "dotnet build $dirName"
    dotnet build
    $build1Sw.Stop()

    $build2Sw = New-Object System.Diagnostics.Stopwatch
    $build2Sw.Start()
    Write-Host "dotnet build $dirName"
    dotnet build
    $build2Sw.Stop()

    popd

    return $cloneSw, $installSw1, $installSw2, $build1Sw, $build2Sw
}

function Print-Build-Sws {
    param (
        $sws,
        $name
    )
    Write-Host "#Clone $name ms:   " $sws[$sws.length - 5].ElapsedMilliseconds
    Write-Host "#Install 1 $name ms: " $sws[$sws.length - 4].ElapsedMilliseconds
    Write-Host "#Install 2 $name ms: " $sws[$sws.length - 3].ElapsedMilliseconds
    Write-Host "#Build1 $name ms:  " $sws[$sws.length - 2].ElapsedMilliseconds
    Write-Host "#Build2 $name ms:  " $sws[$sws.length - 1].ElapsedMilliseconds
}

function Remove-Dir-Patiently {
        param (
        $Path
    )
    if ( (Test-Path -Path $Path -PathType Container) )
    {
        Write-Host "The other way of removing $Path ... that works more often"
        cmd.exe /c "rd /s /q $Path"
    }
    if ( (Test-Path -Path $Path -PathType Container) )
    {
        Write-Host "Removing $Path ..."
        Remove-Item -LiteralPath $Path -Force -Recurse
    }
    if (  (Test-Path -Path $Path -PathType Container) )
    {
        Write-Host "Failed to remove $Path"
        exit
    }
}
Remove-Dir-Patiently -Path "CleanArchitecture"
Remove-Dir-Patiently -Path "minimus" 
Remove-Dir-Patiently -Path "angular-realworld-example-app" 

$cleanASws = DotnetBenchmark-Build -cloneUrl https://github.com/jasontaylordev/CleanArchitecture.git -dirName CleanArchitecture -buildCommand build
Print-Build-Sws $cleanASws -name cleanA
#Ryzen 3600 with SSD
#Clone cleanA ms:    3612, 4327, 4651
#Install 1 cleanA ms:  1344, 1389, 1339
#Install 2 cleanA ms:  872, 896, 842
#Build1 cleanA ms:   48974, 47286, 49033
#Build2 cleanA ms:   4325, 4356, 4767
#Ryzen 2600 with NVMe
#Clone cleanA ms:    3348, 3206
#Install 1 cleanA ms:  1813, 1799
#Install 2 cleanA ms:  1140, 1120
#Build1 cleanA ms:   40525, 40660
#Build2 cleanA ms:   6383, 6480


$minimusSws = NpmBenchmark-Build -cloneUrl https://github.com/hamedbaatour/minimus.git -dirName minimus -buildCommand build
Print-Build-Sws $minimusSws -name minimus
#dell laptop
#Clone minimus ms:  3287, 3339, 3283, 3136
#Install 1 minimus ms:  52926, 51534, 47663, 43418
#Install 2 minimus ms:  12826
#Build1 minimus ms:  26305, 23601, 25595, 21956, 22070
#Build2 minimus ms:  24165, 27011, 28470, 22086, 22390
#Ryzen 3600 with SSD
#Clone minimus ms:    3361
#Install 1 minimus ms:  57934
#Install 2 minimus ms:  34277
#Build1 minimus ms:   10237
#Build2 minimus ms:   9785
#Ryzen 2600 with NVMe
#Clone minimus ms:    2921, 2367
#Install 1 minimus ms:  30479, 33357
#Install 2 minimus ms:  9891, 9204
#Build1 minimus ms:   15079, 14914
#Build2 minimus ms:   14944, 14980


$realSws = NpmBenchmark-Build -cloneUrl https://github.com/gothinkster/angular-realworld-example-app.git -dirName angular-realworld-example-app -buildCommand build
#dell laptop
#Clone realworld ms:  2014, 2052, 2002, 3756
#Install 1 realworld ms:  49557, 52612
#Install 2 realworld ms:  8818
#Build1 realworld ms:  41915, 44690
#Build2 realworld ms:  33535, 33465
#Ryzen 3600 with SSD
#Clone realworld ms:    3660
#Install 1 realworld ms:  36355
#Install 2 realworld ms:  7122
#Build1 realworld ms:   21419
#Build2 realworld ms:   15784
#Ryzen 2600 with NVMe
#Clone realworld ms:    3943
#Install 1 realworld ms:  34493
#Install 2 realworld ms:  6588
#Build1 realworld ms:   29139
#Build2 realworld ms:   21392

Print-Build-Sws $cleanASws -name cleanA
Print-Build-Sws $minimusSws -name minimus
Print-Build-Sws $realSws -name realworld



