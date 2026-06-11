page 88901 "GDRG WC Leaderboard"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GDRG WC Leaderboard";
    SourceTableTemporary = true;
    Permissions = tabledata "GDRG WC Prediction" = r;
    SourceTableView = sorting("Total Points", Username) order(descending);
    Caption = 'World Cup Leaderboard';
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Position; Rec.Position)
                {
                }
                field(Medal; Rec.Medal)
                {
                }
                field(Username; Rec.Username)
                {
                }
                field("Total Points"; Rec."Total Points")
                {
                }
                field(Predictions; Rec.Predictions)
                {
                }
                field(Exacts; Rec.Exacts)
                {
                }
                field(Outcomes; Rec.Outcomes)
                {
                }
                field("Last Updated At"; Rec."Last Updated At")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RefreshLeaderboard)
            {
                Caption = 'Refresh';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Refreshes the leaderboard totals from all predictions.';

                trigger OnAction()
                begin
                    BuildLeaderboard();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        BuildLeaderboard();
    end;

    local procedure BuildLeaderboard()
    var
        PredictionRec: Record "GDRG WC Prediction";
    begin
        Rec.DeleteAll(false);
        BuildLeaderboardRows(PredictionRec);
        ApplyLeaderboardPositions();
    end;

    local procedure BuildLeaderboardRows(var PredictionRec: Record "GDRG WC Prediction")
    var
        TypeHelper: Codeunit "Type Helper";
        CurrentUsername: Text[100];
        CurrentPoints: Integer;
        CurrentPredictions: Integer;
        CurrentExacts: Integer;
        CurrentOutcomes: Integer;
        CurrentLastUpdatedAt: DateTime;
        NextEntryNo: Integer;
    begin
        CurrentPoints := 0;
        CurrentPredictions := 0;
        CurrentExacts := 0;
        CurrentOutcomes := 0;
        CurrentLastUpdatedAt := 0DT;
        NextEntryNo := 0;

        PredictionRec.SetCurrentKey(Username, "Match Date", "Match Time");
        if not PredictionRec.FindSet() then
            exit;

        repeat
            if PredictionRec.Username <> CurrentUsername then begin
                AddLeaderboardRow(NextEntryNo, CurrentUsername, CurrentPoints, CurrentPredictions, CurrentExacts, CurrentOutcomes, CurrentLastUpdatedAt);
                CurrentUsername := PredictionRec.Username;
                CurrentPoints := 0;
                CurrentPredictions := 0;
                CurrentExacts := 0;
                CurrentOutcomes := 0;
                CurrentLastUpdatedAt := 0DT;
            end;

            CurrentPoints += PredictionRec.Points;
            CurrentPredictions += 1;

            if PredictionRec.Points = 3 then
                CurrentExacts += 1;

            if PredictionRec.Points = 1 then
                CurrentOutcomes += 1;

            if TypeHelper.CompareDateTime(PredictionRec."Last Updated At", CurrentLastUpdatedAt) > 0 then
                CurrentLastUpdatedAt := PredictionRec."Last Updated At";
        until PredictionRec.Next() = 0;

        AddLeaderboardRow(NextEntryNo, CurrentUsername, CurrentPoints, CurrentPredictions, CurrentExacts, CurrentOutcomes, CurrentLastUpdatedAt);
    end;

    local procedure ApplyLeaderboardPositions()
    var
        RankPosition: Integer;
    begin
        RankPosition := 0;
        Rec.SetCurrentKey("Total Points", Username);
        Rec.Ascending(false);

        if Rec.FindSet() then
            repeat
                RankPosition += 1;
                Rec.Position := RankPosition;
                Rec.Medal := GetMedal(RankPosition);
                Rec.Modify(false);
            until Rec.Next() = 0;
    end;

    local procedure AddLeaderboardRow(var NextEntryNo: Integer; UsernameText: Text[100]; TotalPoints: Integer; PredictionsCount: Integer; ExactsCount: Integer; OutcomesCount: Integer; LastUpdatedAt: DateTime)
    begin
        if UsernameText = '' then
            exit;

        NextEntryNo += 1;
        Rec.Init();
        Rec."Entry No." := NextEntryNo;
        Rec.Username := UsernameText;
        Rec."Total Points" := TotalPoints;
        Rec.Predictions := PredictionsCount;
        Rec.Exacts := ExactsCount;
        Rec.Outcomes := OutcomesCount;
        Rec."Last Updated At" := LastUpdatedAt;
        Rec.Insert(false);
    end;

    local procedure GetMedal(RankPosition: Integer): Text[10]
    begin
        case RankPosition of
            1:
                exit('🏆');
            2:
                exit('🥈');
            3:
                exit('🥉');
        end;

        exit('');
    end;
}