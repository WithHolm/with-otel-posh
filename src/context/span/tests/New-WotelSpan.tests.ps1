Describe "New-WotelSpan" {
    InModuleScope "With-Otel" {
        BeforeEach {
            Initialize-WotelSingleton
        }
        context "callstack" {
            It "should default to callstack, given no input" {
                { New-WotelSpan } | should -not -throw

                $Traces = Get-WotelTrace -All
                $Traces | Should -HaveCount 1

                $Traces.spans | should -HaveCount 1
            }

            #cannot test. pester arguments contains a stopwatch
            # It "should create id with actual current context id" {
            #     # Write-host "hey"
            #     $Context = Get-PSCallStack
            #     # $SpanCall = $Context[0]
            #     # write-host "testing: $($SpanCall.Command) $($SpanCall.Arguments)"
            #     # Get-WotelSpanId -Callstack $Context
            #     New-WotelSpan -Callstack $Context
            #     $trace = Get-WotelTrace
            #     # Write-host "ho"
            #     $Trace.Spans.keys | Should -Contain (Get-WotelSpanId -Callstack $Context)
            # }

            It "generated trace-Source should be first calling function in stack" {
                New-WotelSpan
                $Traces = Get-WotelTrace -All
                $Traces.name | Should -Be (Get-PSCallStack)[-2].Command
            }

            It "should create a span from callstack" {
                New-WotelSpan
                $Traces = Get-WotelTrace -All
                $Traces.spans.keys
                # $span | Should -Be (Get-PSCallStack)[0].InvocationInfo.HistoryId
            }

            it "Should reflect callers name" {
                function callerFunction {
                    New-WotelSpan
                }
                callerFunction
                $Traces = Get-WotelTrace -All
                $span = $Traces.spans.keys
                $Traces.spans[$span].name | Should -Be 'callerFunction'
            }
            it "Should handle custom span name via -DisplayName" {
                function callerFunction {
                    New-WotelSpan -DisplayName "custom name"
                }
                callerFunction
                $Traces = Get-WotelTrace -All
                $span = $Traces.spans.keys
                $Traces.spans[$span].name | Should -Be 'custom name'
            }
        }
        context "Custom" {
            It "should create a span" {
                $param = @{
                    DisplayName = 'custom'
                    Arguments   = "some=args"
                    File        = (join-path $env:temp 'myfile.txt')
                    SpanId      = "123"
                    ParentId    = "456"
                }
                New-WotelSpan @param
                $Traces = Get-WotelTrace -All
                $Traces.spans[$param.SpanId].name | Should -Be $param.DisplayName
                $Traces.spans[$param.SpanId].arguments | Should -Be $param.Arguments
                $Traces.spans[$param.SpanId].attributes.file | Should -Be ($param.File)
                $Traces.spans[$param.SpanId].context.spanId | Should -Be $param.SpanId
                $Traces.spans[$param.SpanId].context.parentId | Should -Be $param.ParentId
            }
        }
    }
}