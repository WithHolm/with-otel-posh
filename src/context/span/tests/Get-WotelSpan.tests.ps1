Describe "Get-WotelSpan" {
    InModuleScope "with-otel" {
        BeforeEach{
            Initialize-WotelSingleton
        }
        # it "should return span object if span exists" {
        #     # $global:wotel = $null
        #     function testfunction {
        #         param(
        #             $param1
        #         )
        #         New-WotelSpan
        #         @{
        #             span = (Get-WotelSpan)
        #             callstack = (Get-PSCallStack)
        #         }
        #     }
        #     $item = testfunction -param1 "test"
        #     $span = $item.span
        #     $span | Should -not -BeNullOrEmpty
        #     $span|should -BeOfType [wotelspan]
        # }

        # it "should return null if span does not exist" {
        #     # $global:wotel = $null
        #     $param = @{
        #         Callstack = (Get-PSCallStack)
        #     }
        #     $span = Get-WotelSpan @param
        #     $span | Should -BeNullOrEmpty
        # }
        # it "should return span with id based on callstack" {
        #     # $global:wotel = $null
        #     $param = @{
        #         Callstack = (Get-PSCallStack)
        #     }
        #     $span = Get-WotelSpan @param
        #     $span.id | Should -Be (Get-WotelSpanId @param)
        # }

    }
}