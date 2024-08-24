
<#
.SYNOPSIS
Returns a hashtable tree of spans for a given trace id

.PARAMETER TraceId
Parameter description
#>
function Get-WotelSpanTree {
    [CmdletBinding()]
    param (

        [string]$TraceId
    )
    
    begin {
        if(!$global:wotel) {
            Write-Error "Logs are not written yet" -ea Stop
            return
        }
        $Log = $global:wotel.($TraceId)
        if(!$Log) {
            Write-Error "TraceId '$TraceId' not found in logs" -ea Stop
            return
        }
    }
    
    process {
        $spans = $Log|select span,parent,@{n='spcom';e={$_.Attributes.SpanCommand}},@{n='parcom';e={$_.Attributes.ParentCommand}}
        # $spans|%{
        #     Write-Verbose "Span: $($_.span) Parent: $($_.parent) SpanCommand: $($_.spcom) ParentCommand: $($_.parcom)"
        # }
        #Explain: im trying to find the "call tree" of the spans. im first getting the span that started it (usually '<scriptblock>'), and then working my way up the tree
        $UniqueSpans = ($Spans|select -Unique span).span
        $UniqueParents = ($Spans|select -Unique parent).parent

        # finding items that are in the parent list, but not in the span list (the root of the tree)
        $SpanTree = [ordered]@{}
        $index = 0
        $UniqueParents|?{$_ -notin $UniqueSpans}|%{
            $SpanId = $_
            $SpanTree.($SpanTree.Count)=@{
                name = ($spans|?{$_.parent -eq $SpanId}|select -First 1).parcom
                parent = $null
                id = $SpanId
                children = @()
                index = $index
            }
        }

        # while there are new spans to add to the parent list
        # by adding items to the parent lit of the end of the iteration you avoid adding a potential child of child.
        $index++
        While($true){
            $NewSpanTree = @()
            #find all spans that have a parent in the parent list
            $spans|?{$_.parent -in $SpanTree.values.id}|%{
                $NewSpanTree += $_.span
            }

            #add the new spans to the spantree list, while also adding itself to the parents 'child' list.
            $NewSpanTree|select -Unique|%{
                $SpanId = $_
                $item = $spans|?{$_.Span -eq $SpanId}|select -First 1
                $AddSpan = @{
                    name = $item.spcom
                    parent = $item.parent
                    id = $item.span
                    children = @()
                    index = $index
                }

                $parent = $SpanTree.Values|?{$_.id -eq $item.parent}
                $parent.children += $AddSpan
                $SpanTree.($SpanTree.Count) = $AddSpan
            }

            $Spans = $Spans|?{$_.span -notin $SpanTree.Values.id}

            if($NewSpanTree.Count -eq 0){
                if($spans.count -gt 0){
                    Throw "Error getting span tree, $($spans.count) spans left to process, but none of them have a parent in the span tree."
                }
                break
            }
            $index++
        }

        return $SpanTree.values
    }
    
    end {
        
    }
}