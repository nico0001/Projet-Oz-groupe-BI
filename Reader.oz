functor
import
    Open
export
    textfile:TextFile
    scan:Scan
    fullscan:FullScan

define
    % Fetches the N-th line in a file
    % @pre: - InFile: a TextFile from the file
    %       - N: the desires Nth line
    % @post: Returns the N-the line or 'none' in case it doesn't exist
    fun {Scan InFile N}
        Line={InFile getS($)}
    in
        if Line==false then
            {InFile close}
            none
        else
            if N==1 then
                {InFile close}
                Line
            else
                {Scan InFile N-1}
            end
        end
    end

    %Fetches all the line in a file in a stream format
    % @pre: - InFile: a TextFile from the file
    %       - N : Determine the pair or impair files
    % @post: Returns a stream containing the lines of pair or impair files: Line1|Line3|...|Line99|nil
    fun {FullScan InFile N}
        Line={InFile getS($)}
    in
        if Line==false then
            {InFile close}
            if N==100 then
                nil
            else 
                if N==99 then
                    nil
                else
                    {FullScan {New TextFile init(name:"tweets/part_"#N+2#".txt")} N+2}
                end
            end
        else
            Line|{FullScan InFile N}
        end
    end

    class TextFile % This class enables line-by-line reading
        from Open.file Open.text
    end

end