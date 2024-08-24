all commands should have follow "{verb}-WotelWriter{yourWriter}{thing to do}"

Expected commands:
Initialize-WotelWriter{YourWriter}
    return the settings object for the writer

NOTE: to get your setting object, you should use Get-WotelSetting -Key "writers.{YourWriter}". 
dont try to use the global object directly as any changes to the global objects name will break your code :)

Invoke-WotelWriter{YourWiter}
    param: all params that defined a otel event (steal it from console writer)
    should do the thing with the otel object. how you do it is up to you, but i suggest that you use a runspace to do it.

you should also add your writer and its settings to **Initialize-WotelSettings** and **Invoke-WotelWriters**. the last command have log object, trace object and span object available, so you can use them to do your thing. please dont add any 