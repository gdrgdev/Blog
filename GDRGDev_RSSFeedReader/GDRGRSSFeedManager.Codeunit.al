codeunit 80100 "GDRG RSS Feed Manager"
{
    Permissions = tabledata "GDRG RSS Feed Source" = RIMD,
                  tabledata "GDRG RSS Feed Entry" = RIMD,
                  tabledata "GDRG RSS Feed Setup" = RIMD;

    /// <summary>
    /// Fetches RSS feed content from the specified feed source and parses it into entries.
    /// Supports both RSS 2.0 and Atom formats. Updates the Last Refresh DateTime upon successful completion.
    /// </summary>
    /// <param name="FeedCode">The code of the RSS feed source to fetch and parse.</param>
    procedure FetchAndParseFeed(FeedCode: Code[20])
    var
        FeedSource: Record "GDRG RSS Feed Source";
        HttpClient: HttpClient;
        HttpResponse: HttpResponseMessage;
        ResponseText: Text;
    begin
        if not FeedSource.Get(FeedCode) then
            exit;

        if not FeedSource.Active then
            exit;

        if FeedSource."Feed URL" = '' then
            exit;

        HttpClient.DefaultRequestHeaders().Add('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36');
        HttpClient.DefaultRequestHeaders().Add('Accept', 'application/rss+xml, application/xml, text/xml, */*');

        if not HttpClient.Get(FeedSource."Feed URL", HttpResponse) then
            exit;

        if not HttpResponse.IsSuccessStatusCode() then
            exit;

        HttpResponse.Content().ReadAs(ResponseText);
        ParseRSSContent(ResponseText, FeedCode);

        FeedSource."Last Refresh DateTime" := CurrentDateTime();
        FeedSource.Modify(true);
    end;

    local procedure ParseRSSContent(ResponseText: Text; FeedCode: Code[20])
    var
        XmlDoc: XmlDocument;
    begin
        if not XmlDocument.ReadFrom(ResponseText, XmlDoc) then
            exit;

        if IsRSS20Format(XmlDoc) then
            ParseRSS20(XmlDoc, FeedCode)
        else
            if IsAtomFormat(XmlDoc) then
                ParseAtom(XmlDoc, FeedCode);
    end;

    local procedure IsRSS20Format(XmlDoc: XmlDocument): Boolean
    var
        RootNode: XmlElement;
    begin
        if not XmlDoc.GetRoot(RootNode) then
            exit(false);

        exit(RootNode.Name() = 'rss');
    end;

    local procedure IsAtomFormat(XmlDoc: XmlDocument): Boolean
    var
        RootNode: XmlElement;
    begin
        if not XmlDoc.GetRoot(RootNode) then
            exit(false);

        exit(RootNode.Name() = 'feed');
    end;

    local procedure ParseRSS20(XmlDoc: XmlDocument; FeedCode: Code[20])
    var
        RootNode: XmlElement;
        ChannelNode: XmlNode;
        ItemNodes: XmlNodeList;
        ItemNode: XmlNode;
        ItemElement: XmlElement;
    begin
        if not XmlDoc.GetRoot(RootNode) then
            exit;

        if not RootNode.SelectSingleNode('channel', ChannelNode) then
            exit;

        if not ChannelNode.AsXmlElement().SelectNodes('item', ItemNodes) then
            exit;

        DeleteExistingEntries(FeedCode);

        foreach ItemNode in ItemNodes do begin
            ItemElement := ItemNode.AsXmlElement();
            CreateEntryFromRSS20Item(ItemElement, FeedCode);
        end;
    end;

    local procedure ParseAtom(XmlDoc: XmlDocument; FeedCode: Code[20])
    var
        RootNode: XmlElement;
        EntryNodes: XmlNodeList;
        EntryNode: XmlNode;
        EntryElement: XmlElement;
    begin
        if not XmlDoc.GetRoot(RootNode) then
            exit;

        if not RootNode.SelectNodes('entry', EntryNodes) then
            exit;

        DeleteExistingEntries(FeedCode);

        foreach EntryNode in EntryNodes do begin
            EntryElement := EntryNode.AsXmlElement();
            CreateEntryFromAtomEntry(EntryElement, FeedCode);
        end;
    end;

    local procedure CreateEntryFromRSS20Item(ItemElement: XmlElement; FeedCode: Code[20])
    var
        RSSEntry: Record "GDRG RSS Feed Entry";
        FeedSource: Record "GDRG RSS Feed Source";
        TitleNode: XmlNode;
        LinkNode: XmlNode;
        DescNode: XmlNode;
        PubDateNode: XmlNode;
    begin
        RSSEntry.Init();
        RSSEntry."Feed Code" := FeedCode;
        RSSEntry."Fetched DateTime" := CurrentDateTime();

        if FeedSource.Get(FeedCode) then
            RSSEntry.Category := FeedSource.Category;

        if ItemElement.SelectSingleNode('title', TitleNode) then
            RSSEntry.Title := CopyStr(TitleNode.AsXmlElement().InnerText(), 1, MaxStrLen(RSSEntry.Title));

        if ItemElement.SelectSingleNode('link', LinkNode) then
            RSSEntry.Link := CopyStr(LinkNode.AsXmlElement().InnerText(), 1, MaxStrLen(RSSEntry.Link));

        if ItemElement.SelectSingleNode('description', DescNode) then
            RSSEntry.Description := CopyStr(CleanDescription(DescNode.AsXmlElement().InnerText()), 1, MaxStrLen(RSSEntry.Description));

        if ItemElement.SelectSingleNode('pubDate', PubDateNode) then
            RSSEntry."Published Date" := ParseRFC822Date(PubDateNode.AsXmlElement().InnerText());

        if RSSEntry.Title <> '' then
            RSSEntry.Insert(true);
    end;

    local procedure CreateEntryFromAtomEntry(EntryElement: XmlElement; FeedCode: Code[20])
    var
        RSSEntry: Record "GDRG RSS Feed Entry";
        FeedSource: Record "GDRG RSS Feed Source";
        TitleNode: XmlNode;
        LinkNode: XmlNode;
        SummaryNode: XmlNode;
        UpdatedNode: XmlNode;
        LinkElement: XmlElement;
        HrefAttr: XmlAttribute;
    begin
        RSSEntry.Init();
        RSSEntry."Feed Code" := FeedCode;
        RSSEntry."Fetched DateTime" := CurrentDateTime();

        if FeedSource.Get(FeedCode) then
            RSSEntry.Category := FeedSource.Category;

        if EntryElement.SelectSingleNode('title', TitleNode) then
            RSSEntry.Title := CopyStr(TitleNode.AsXmlElement().InnerText(), 1, MaxStrLen(RSSEntry.Title));

        if EntryElement.SelectSingleNode('link', LinkNode) then begin
            LinkElement := LinkNode.AsXmlElement();
            if LinkElement.Attributes().Get('href', HrefAttr) then
                RSSEntry.Link := CopyStr(HrefAttr.Value(), 1, MaxStrLen(RSSEntry.Link));
        end;

        if EntryElement.SelectSingleNode('summary', SummaryNode) then
            RSSEntry.Description := CopyStr(CleanDescription(SummaryNode.AsXmlElement().InnerText()), 1, MaxStrLen(RSSEntry.Description));

        if EntryElement.SelectSingleNode('updated', UpdatedNode) then
            RSSEntry."Published Date" := ParseISO8601Date(UpdatedNode.AsXmlElement().InnerText());

        if RSSEntry.Title <> '' then
            RSSEntry.Insert(true);
    end;

    local procedure ParseRFC822Date(DateText: Text): DateTime
    var
        DateTimeParts: List of [Text];
        Day, Month, Year, TimeText : Text;
        MonthNum: Integer;
        ParsedTime: Time;
    begin
        if DateText = '' then
            exit(CurrentDateTime());

        DateTimeParts := DateText.Split(' ');
        if DateTimeParts.Count() < 5 then
            exit(CurrentDateTime());

        Day := DateTimeParts.Get(2);
        Month := DateTimeParts.Get(3);
        Year := DateTimeParts.Get(4);
        TimeText := DateTimeParts.Get(5);

        MonthNum := GetMonthNumber(Month);
        ParsedTime := ParseTimeFromRFC822(TimeText);

        exit(CreateDateTime(DMY2Date(ConvertToInteger(Day), MonthNum, ConvertToInteger(Year)), ParsedTime));
    end;

    local procedure ParseTimeFromRFC822(TimeText: Text): Time
    var
        TimeParts: List of [Text];
        Hour, Minute, Second : Integer;
        ResultTime: Time;
    begin
        TimeParts := TimeText.Split(':');
        if TimeParts.Count() < 3 then
            exit(0T);

        if not Evaluate(Hour, TimeParts.Get(1)) then
            exit(0T);

        if not Evaluate(Minute, TimeParts.Get(2)) then
            exit(0T);

        if not Evaluate(Second, TimeParts.Get(3)) then
            exit(0T);

        if Evaluate(ResultTime, Format(Hour) + ':' + Format(Minute) + ':' + Format(Second)) then
            exit(ResultTime);

        exit(0T);
    end;

    local procedure ParseISO8601Date(DateText: Text): DateTime
    var
        ResultDateTime: DateTime;
    begin
        if Evaluate(ResultDateTime, DateText) then
            exit(ResultDateTime);

        exit(CurrentDateTime());
    end;

    local procedure GetMonthNumber(MonthText: Text): Integer
    begin
#pragma warning disable AA0090
        case MonthText of
            'Jan':
                exit(1);
            'Feb':
                exit(2);
            'Mar':
                exit(3);
            'Apr':
                exit(4);
            'May':
                exit(5);
            'Jun':
                exit(6);
            'Jul':
                exit(7);
            'Aug':
                exit(8);
            'Sep':
                exit(9);
            'Oct':
                exit(10);
            'Nov':
                exit(11);
            'Dec':
                exit(12);
            else
                exit(1);
        end;
#pragma warning restore AA0090
    end;

    local procedure ConvertToInteger(TextValue: Text): Integer
    var
        IntValue: Integer;
    begin
        if Evaluate(IntValue, TextValue) then
            exit(IntValue);

        exit(1);
    end;

    local procedure CleanDescription(InputText: Text): Text
    var
        CleanedText: Text;
    begin
        CleanedText := RemoveHtmlTags(InputText);
        CleanedText := TrimText(CleanedText);
        exit(CleanedText);
    end;

    local procedure RemoveHtmlTags(InputText: Text): Text
    var
        CleanedText: Text;
    begin
        CleanedText := InputText;
        CleanedText := CleanedText.Replace('</p>', '');
        CleanedText := CleanedText.Replace('<p>', '');
        CleanedText := CleanedText.Replace('<br>', '');
        CleanedText := CleanedText.Replace('<br/>', '');
        CleanedText := CleanedText.Replace('</br>', '');
        CleanedText := CleanedText.Replace('<div>', '');
        CleanedText := CleanedText.Replace('</div>', '');
        CleanedText := CleanedText.Replace('<span>', '');
        CleanedText := CleanedText.Replace('</span>', '');
        CleanedText := CleanedText.Replace('<strong>', '');
        CleanedText := CleanedText.Replace('</strong>', '');
        CleanedText := CleanedText.Replace('<em>', '');
        CleanedText := CleanedText.Replace('</em>', '');
        CleanedText := CleanedText.Replace('<a>', '');
        CleanedText := CleanedText.Replace('</a>', '');
        CleanedText := CleanedText.Replace('<ul>', '');
        CleanedText := CleanedText.Replace('</ul>', '');
        CleanedText := CleanedText.Replace('<li>', '');
        CleanedText := CleanedText.Replace('</li>', '');
        CleanedText := CleanedText.Replace('<h1>', '');
        CleanedText := CleanedText.Replace('</h1>', '');
        CleanedText := CleanedText.Replace('<h2>', '');
        CleanedText := CleanedText.Replace('</h2>', '');
        CleanedText := CleanedText.Replace('<h3>', '');
        CleanedText := CleanedText.Replace('</h3>', '');
        CleanedText := CleanedText.Replace('<h4>', '');
        CleanedText := CleanedText.Replace('</h4>', '');
        CleanedText := CleanedText.Replace('<h5>', '');
        CleanedText := CleanedText.Replace('</h5>', '');
        CleanedText := CleanedText.Replace('<h6>', '');
        CleanedText := CleanedText.Replace('</h6>', '');
        CleanedText := CleanedText.Replace('&nbsp;', ' ');
        CleanedText := CleanedText.Replace('&quot;', '"');
        CleanedText := CleanedText.Replace('&amp;', '&');
        CleanedText := CleanedText.Replace('&lt;', '<');
        CleanedText := CleanedText.Replace('&gt;', '>');
        CleanedText := CleanedText.Replace('&apos;', '''');
        exit(CleanedText);
    end;

    local procedure TrimText(InputText: Text): Text
    var
        TypeHelper: Codeunit "Type Helper";
        CleanedText: Text;
        Tab: Char;
    begin
        CleanedText := InputText;
        Tab := 9;
        CleanedText := DelChr(CleanedText, '<>', ' ' + Format(Tab) + TypeHelper.LFSeparator() + TypeHelper.CRLFSeparator());
        exit(CleanedText);
    end;

    local procedure DeleteExistingEntries(FeedCode: Code[20])
    var
        RSSEntry: Record "GDRG RSS Feed Entry";
    begin
        RSSEntry.SetRange("Feed Code", FeedCode);
        RSSEntry.DeleteAll(true);
    end;

    /// <summary>
    /// Determines whether an RSS feed should be refreshed based on the configured refresh interval.
    /// Checks both custom intervals (if specified) and default refresh settings.
    /// </summary>
    /// <param name="FeedCode">The code of the RSS feed source to check.</param>
    /// <returns>True if the feed should be refreshed, false otherwise.</returns>
    procedure ShouldRefresh(FeedCode: Code[20]): Boolean
    var
        FeedSource: Record "GDRG RSS Feed Source";
        RSSSetup: Record "GDRG RSS Feed Setup";
        MinutesSinceRefresh: Decimal;
        RefreshInterval: Integer;
    begin
        if not FeedSource.Get(FeedCode) then
            exit(false);

        if FeedSource."Last Refresh DateTime" = 0DT then
            exit(true);

        MinutesSinceRefresh := (CurrentDateTime() - FeedSource."Last Refresh DateTime") / 60000;

        if FeedSource."Use Custom Interval" then
            RefreshInterval := FeedSource."Refresh Interval Minutes"
        else begin
            RSSSetup.GetInstance();
            RefreshInterval := RSSSetup."Default Refresh Minutes";
        end;

        exit(MinutesSinceRefresh >= RefreshInterval);
    end;

    /// <summary>
    /// Retrieves RSS feed entries for the specified feed source.
    /// Automatically refreshes the feed if the refresh interval has elapsed.
    /// </summary>
    /// <param name="FeedCode">The code of the RSS feed source to retrieve entries from.</param>
    procedure GetFeedEntries(FeedCode: Code[20])
    begin
        if ShouldRefresh(FeedCode) then
            FetchAndParseFeed(FeedCode);
    end;

    /// <summary>
    /// Removes RSS feed entries older than the specified number of days.
    /// This helps maintain database performance by removing outdated cached entries.
    /// </summary>
    /// <param name="KeepDays">The number of days to keep entries. Entries older than this will be deleted.</param>
    procedure CleanupOldEntries(KeepDays: Integer)
    var
        RSSEntry: Record "GDRG RSS Feed Entry";
        CutoffDateTime: DateTime;
    begin
        CutoffDateTime := CreateDateTime(Today() - KeepDays, 0T);

        RSSEntry.SetFilter("Fetched DateTime", '<%1', CutoffDateTime);
        RSSEntry.DeleteAll(true);
    end;
}
