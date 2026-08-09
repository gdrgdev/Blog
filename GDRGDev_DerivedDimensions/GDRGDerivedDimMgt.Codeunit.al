/// <summary>
/// Helpers to stage and commit dimension changes.
/// </summary>
codeunit 88892 "GDRG Derived Dim Mgt."
{
    Permissions = tabledata Dimension = R,
                  tabledata "Dimension Value" = RI;

    /// <summary>
    /// Stages one dimension value.
    /// </summary>
    procedure StageDim(var TempDimSetEntry: Record "Dimension Set Entry" temporary; DimensionCode: Code[20]; DimensionValueCode: Code[20]; DimensionValueName: Text[50])
    var
        Dimension: Record Dimension;
        DimValue: Record "Dimension Value";
    begin
        if DimensionValueCode = '' then
            exit;
        if not Dimension.Get(DimensionCode) then
            exit;

        if not DimValue.Get(DimensionCode, DimensionValueCode) then begin
            DimValue.Init();
            DimValue."Dimension Code" := DimensionCode;
            DimValue.Code := DimensionValueCode;
            DimValue.Validate(Name, CopyStr(DimensionValueName, 1, MaxStrLen(DimValue.Name)));
            DimValue.Insert(true);
        end;

        if TempDimSetEntry.Get(0, DimensionCode) then begin
            TempDimSetEntry."Dimension Value Code" := DimensionValueCode;
            TempDimSetEntry."Dimension Value ID" := DimValue."Dimension Value ID";
            TempDimSetEntry.Modify(false);
        end else begin
            TempDimSetEntry.Init();
            TempDimSetEntry."Dimension Code" := DimensionCode;
            TempDimSetEntry."Dimension Value Code" := DimensionValueCode;
            TempDimSetEntry."Dimension Value ID" := DimValue."Dimension Value ID";
            TempDimSetEntry.Insert(false);
        end;
    end;

    /// <summary>
    /// Merges staged entries into the current dimension set.
    /// </summary>
    procedure CommitStagedDims(var DimSetID: Integer; var TempDimSetEntry: Record "Dimension Set Entry" temporary)
    var
        TempCurrentDimSetEntry: Record "Dimension Set Entry" temporary;
        DimensionManagement: Codeunit DimensionManagement;
    begin
        if TempDimSetEntry.IsEmpty() then
            exit;

        DimensionManagement.GetDimensionSet(TempCurrentDimSetEntry, DimSetID);

        if TempDimSetEntry.FindSet() then
            repeat
                if TempCurrentDimSetEntry.Get(DimSetID, TempDimSetEntry."Dimension Code") then begin
                    TempCurrentDimSetEntry."Dimension Value Code" := TempDimSetEntry."Dimension Value Code";
                    TempCurrentDimSetEntry."Dimension Value ID" := TempDimSetEntry."Dimension Value ID";
                    TempCurrentDimSetEntry.Modify(false);
                end else begin
                    TempCurrentDimSetEntry := TempDimSetEntry;
                    TempCurrentDimSetEntry."Dimension Set ID" := DimSetID;
                    TempCurrentDimSetEntry.Insert(false);
                end;
            until TempDimSetEntry.Next() = 0;

        DimSetID := DimensionManagement.GetDimensionSetID(TempCurrentDimSetEntry);
    end;

}
