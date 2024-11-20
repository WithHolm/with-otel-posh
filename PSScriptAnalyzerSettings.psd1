@{
    ExcludeRules = @(
        'PSAvoidUsingWriteHost' #using alot of write host
        # "PSAvoidGlobalVars" #using global variables
        "PSUseShouldProcessForStateChangingFunctions" #using standard pwsh verbs that dont change system state #TODO: i will have to fix this
    )
    CustomRulePath = @(
        ".\AnalyzerRules"
    )
    IncludeDefaultRules = $true
    IncludeRules = @(
        "PS*"
        "Measure-*"
    )
}