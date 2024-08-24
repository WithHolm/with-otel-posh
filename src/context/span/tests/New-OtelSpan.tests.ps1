Describe "New-WotelSpan" {
    InModuleScope "bolt.core" {
        context "callstack" {
            It "should default to callstack, given no input" {
                $global:wotel = $null
                { New-WotelSpan } | should -not -throw

                $global:wotel | Should -HaveCount 1
                $traceId = $global:wotel.Keys
                $global:wotel[$traceId].spans | should -HaveCount 1
                # $global:wotel[$traceId].spans.Keys | should -Be (Get-PSCallStack)[0].InvocationInfo.HistoryId
            }
            It "generated trace-Source should be first calling function in stack" {
                $global:wotel = $null
                New-WotelSpan
                $traceId = $global:wotel.keys
                $global:wotel[$traceId].name | Should -Be (Get-PSCallStack)[-2].Command
            }

            It "should create a span from callstack" {
                $global:wotel = $null
                New-WotelSpan
                $traceId = $global:wotel.Keys
                $span = $global:wotel[$traceId].spans.keys
                # $span | Should -Be (Get-PSCallStack)[0].InvocationInfo.HistoryId
            }

            it "Should reflect callers name"{
                $global:wotel = $null
                function callerFunction {
                    New-WotelSpan
                }
                callerFunction
                $traceId = $global:wotel.Keys
                $span = $global:wotel[$traceId].spans.keys
                $global:wotel[$traceId].spans[$span].name | Should -Be 'callerFunction'
            }
            it "Should handle custom span name via -DisplayName"{
                $global:wotel = $null
                function callerFunction {
                    New-WotelSpan -DisplayName "custom name"
                }
                callerFunction
                $traceId = $global:wotel.Keys
                $span = $global:wotel[$traceId].spans.keys
                $global:wotel[$traceId].spans[$span].name | Should -Be 'custom name'
            }
        }
        context "Custom"{
            It "should create a span" {
                $global:wotel = $null
                $param = @{
                    DisplayName = 'custom'
                    Arguments   = "some=args"
                    File        = (join-path $env:temp 'myfile.txt')
                    SpanId      = "123"
                    ParentId    = "456"
                }
                New-WotelSpan @param
                $traceId = $global:wotel.Keys
                $span = $global:wotel[$traceId].spans.keys
                $global:wotel[$traceId].spans[$span].name | Should -Be $param.DisplayName
                $global:wotel[$traceId].spans[$span].arguments | Should -Be $param.Arguments
                $global:wotel[$traceId].spans[$span].file | Should -Be ([System.IO.FileInfo]$param.File).FullName
                $global:wotel[$traceId].spans[$span].id | Should -Be $param.SpanId
                $global:wotel[$traceId].spans[$span].parent | Should -Be $param.ParentId
            }
            # this is really not neccecary.. parent isnt really used atm
            # it "Should default to current callstack context on callstack if parent is not provided"{
            #     $global:wotel = $null
            #     $param = @{
            #         DisplayName = 'custom'
            #         Arguments   = "some=args"
            #         File        = (join-path $env:temp 'myfile.txt')
            #         SpanId      = "123"
            #     }
            #     New-WotelSpan @param
            #     $traceId = $global:wotel.Keys
            #     $span = $global:wotel[$traceId].spans.keys
            #     $global:wotel[$traceId].spans[$span].parent | Should -Be (Get-PSCallStack)[0].InvocationInfo.HistoryId
            # }
        }
    }
}