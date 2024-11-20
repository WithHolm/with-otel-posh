Describe "Get-WotelSpanId" {
    InModuleScope "with-otel" {
        BeforeEach{
            Initialize-WotelSingleton
        }
        #returns id of the current span. first 18 characters is the command name, second 19 is the arguments, they are divided by a semicolon
        it "should a span id based on the current callstack" {
            $global:wotel = $null
            $param = @{
                Callstack = (Get-PSCallStack)
            }

            Get-WotelSpanId @param | Should -not -BeNullOrEmpty
        }

        it "first part should represent command name" {
            function testfunction {
                param(
                    $param1
                )
                @{
                    span = (Get-WotelSpanId)
                    callstack = (Get-PSCallStack)
                }
            }
            $info = testfunction -param1 "test"
            $res = $info.span
            $callstack = $info.callstack


            $test = New-GuidV5 -Name $callstack[0].command
            $res.split(":")[0] | Should -Be $test.ToString().Substring(0, 18)
        }
        it "second part should represent arguments" {
            function testfunction {
                param(
                    $param1
                )
                @{
                    span = (Get-WotelSpanId)
                    callstack = (Get-PSCallStack)
                }
            }
            $info = testfunction -param1 "test"
            $res = $info.span
            $callstack = $info.callstack


            $test = New-GuidV5 -Name $callstack[0].arguments
            $res.split(":")[1] | Should -Be $test.ToString().Substring(19)
        }

        it "should always return same id given same function and arguments" {
            function testfunction {
                param(
                    $param1
                )
                Get-WotelSpanId
            }
            
            $res = testfunction -param1 "test"
            $res2 = testfunction -param1 "test"
            $res | Should -Be $res2
        }
    }
}