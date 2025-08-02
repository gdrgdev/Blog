codeunit 50100 "GDRG Personal Tag Manager"
{
    Permissions = tabledata "GDRG Personal Tag Assignment" = RIMD,
    tabledata "GDRG Personal Tag Master" = RIMD;

    procedure AddTag(RecordVariant: Variant; TagCode: Code[20])
    var
        PersonalTagAssignment: Record "GDRG Personal Tag Assignment";
        PersonalTagMaster: Record "GDRG Personal Tag Master";
        RecRef: RecordRef;
        CurrentUser: Code[50];
        TagNotExistErr: Label 'Tag %1 does not exist. Please create it first.', Comment = '%1 = Tag Code';
        TagAlreadyExistsErr: Label 'Tag %1 is already assigned to this record.', Comment = '%1 = Tag Code';
    begin
        RecRef.GetTable(RecordVariant);
        CurrentUser := CopyStr(UserId(), 1, 50);

        // Check if tag exists in master
        PersonalTagMaster.SetRange("User ID", CurrentUser);
        PersonalTagMaster.SetRange(Code, TagCode);
        if PersonalTagMaster.IsEmpty() then
            Error(TagNotExistErr, TagCode);

        // Check if assignment already exists
        PersonalTagAssignment.SetRange("User ID", CurrentUser);
        PersonalTagAssignment.SetRange("Tag Code", TagCode);
        PersonalTagAssignment.SetRange("Table No.", RecRef.Number());
        PersonalTagAssignment.SetRange("Record ID", RecRef.RecordId());
        if not PersonalTagAssignment.IsEmpty() then
            Error(TagAlreadyExistsErr, TagCode);

        // Create assignment
        PersonalTagAssignment.Init();
        PersonalTagAssignment."User ID" := CurrentUser;
        PersonalTagAssignment."Tag Code" := TagCode;
        PersonalTagAssignment."Table No." := RecRef.Number();
        PersonalTagAssignment."Record ID" := RecRef.RecordId();
        PersonalTagAssignment.Insert(true);
    end;

    procedure CreateTag(TagCode: Code[20]; TagName: Text[50]; TagColor: Enum "GDRG Color"; Description: Text[100])
    var
        PersonalTagMaster: Record "GDRG Personal Tag Master";
        CurrentUser: Code[50];
    begin
        CurrentUser := CopyStr(UserId(), 1, 50);

        PersonalTagMaster.Init();
        PersonalTagMaster."User ID" := CurrentUser;
        PersonalTagMaster.Code := TagCode;
        PersonalTagMaster.Name := TagName;
        PersonalTagMaster.Color := TagColor;
        PersonalTagMaster.Description := Description;

        PersonalTagMaster.Insert(true);
    end;

    procedure RemoveTag(RecordVariant: Variant; TagCode: Code[20])
    var
        PersonalTagAssignment: Record "GDRG Personal Tag Assignment";
        RecRef: RecordRef;
        CurrentUser: Code[50];
    begin
        RecRef.GetTable(RecordVariant);
        CurrentUser := CopyStr(UserId(), 1, 50);

        PersonalTagAssignment.SetRange("User ID", CurrentUser);
        PersonalTagAssignment.SetRange("Tag Code", TagCode);
        PersonalTagAssignment.SetRange("Table No.", RecRef.Number());
        PersonalTagAssignment.SetRange("Record ID", RecRef.RecordId());

        if PersonalTagAssignment.FindFirst() then
            PersonalTagAssignment.Delete(true);
    end;

    procedure GetRecordTags(RecordVariant: Variant): List of [Text]
    var
        PersonalTagAssignment: Record "GDRG Personal Tag Assignment";
        RecRef: RecordRef;
        TagList: List of [Text];
        CurrentUser: Code[50];
    begin
        RecRef.GetTable(RecordVariant);
        CurrentUser := CopyStr(UserId(), 1, 50);

        PersonalTagAssignment.SetRange("User ID", CurrentUser);
        PersonalTagAssignment.SetRange("Table No.", RecRef.Number());
        PersonalTagAssignment.SetRange("Record ID", RecRef.RecordId());

        if PersonalTagAssignment.FindSet() then
            repeat
                PersonalTagAssignment.CalcFields("Tag Name");
                TagList.Add(PersonalTagAssignment."Tag Name");
            until PersonalTagAssignment.Next() = 0;

        exit(TagList);
    end;

    procedure GetUserTags(UserID: Code[50]): List of [Text]
    var
        PersonalTagMaster: Record "GDRG Personal Tag Master";
        TagList: List of [Text];
    begin
        PersonalTagMaster.SetRange("User ID", UserID);
        if PersonalTagMaster.FindSet() then
            repeat
                TagList.Add(PersonalTagMaster.Name);
            until PersonalTagMaster.Next() = 0;

        exit(TagList);
    end;

    procedure SearchByTag(TagCode: Code[20]): List of [RecordId]
    var
        PersonalTagAssignment: Record "GDRG Personal Tag Assignment";
        RecordList: List of [RecordId];
        CurrentUser: Code[50];
    begin
        CurrentUser := CopyStr(UserId(), 1, 50);

        PersonalTagAssignment.SetRange("User ID", CurrentUser);
        PersonalTagAssignment.SetRange("Tag Code", TagCode);

        if PersonalTagAssignment.FindSet() then
            repeat
                RecordList.Add(PersonalTagAssignment."Record ID");
            until PersonalTagAssignment.Next() = 0;

        exit(RecordList);
    end;

    procedure HasTag(RecordVariant: Variant; TagCode: Code[20]): Boolean
    var
        PersonalTagAssignment: Record "GDRG Personal Tag Assignment";
        RecRef: RecordRef;
        CurrentUser: Code[50];
    begin
        RecRef.GetTable(RecordVariant);
        CurrentUser := CopyStr(UserId(), 1, 50);

        PersonalTagAssignment.SetRange("User ID", CurrentUser);
        PersonalTagAssignment.SetRange("Tag Code", TagCode);
        PersonalTagAssignment.SetRange("Table No.", RecRef.Number());
        PersonalTagAssignment.SetRange("Record ID", RecRef.RecordId());

        exit(not PersonalTagAssignment.IsEmpty());
    end;

    procedure GetTagColor(RecordVariant: Variant; TagCode: Code[20]): Enum "GDRG Color"
    var
        PersonalTagAssignment: Record "GDRG Personal Tag Assignment";
        RecRef: RecordRef;
        CurrentUser: Code[50];
    begin
        RecRef.GetTable(RecordVariant);
        CurrentUser := CopyStr(UserId(), 1, 50);

        PersonalTagAssignment.SetRange("User ID", CurrentUser);
        PersonalTagAssignment.SetRange("Tag Code", TagCode);
        PersonalTagAssignment.SetRange("Table No.", RecRef.Number());
        PersonalTagAssignment.SetRange("Record ID", RecRef.RecordId());

        if PersonalTagAssignment.FindFirst() then begin
            PersonalTagAssignment.CalcFields("Tag Color");
            exit(PersonalTagAssignment."Tag Color");
        end;

        exit(PersonalTagAssignment."Tag Color"::" ");
    end;
}
