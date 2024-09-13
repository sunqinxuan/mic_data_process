function wordrpt(var1, var2, var3)
% ����Matlab�Զ�����word����. Refs:
%   https://zhuanlan.zhihu.com/p/350652763
%   https://blog.csdn.net/weixin_47919042/article/details/120156511
%   https://wenku.baidu.com/view/955424cd561810a6f524ccbff121dd36a32dc4d3.html?_wkts_=1670851263863&bdQuery=matlab+Shape.AddPicture
%   ����Matlab��word�����Զ����ɷ����о�
%
% Prototype: wordrpt(var1, var2, var3)
% Inputs: var1, var2, var3 - input parameters, please see the code
%
% Example:
% wordrpt(0); wordrpt([800;600])
% for k=1:5
%     wordrpt(sprintf('��%d�ڱ���', k), k);
%     wordrpt('	Say something...');
%     myfig, plot(randn(10,1)); grid on 
%     wordrpt(gcf, 'xxx'); close(gcf);
% end
% wordrpt(-1);

% Copyright(c) 2009-2022, by Gongmin Yan, All rights reserved.
% Northwestern Polytechnical University, Xi An, P.R.China
% 12/12/2022
global ActxWord Doc figno figwh
    if isempty(ActxWord)
        try     % ���Word�������Ѵ򿪣���ֱ�ӷ�������
            ActxWord = actxGetRunningServer('Word.Application');  ActxWord.Visible = 1;
        catch   % ����Word������
            ActxWord = actxserver('Word.Application'); 
        end
    end
    if isnumeric(var1)
        if var1(1)==0,
            Doc=ActxWord.Documents.Add;  Doc.Content.Start=0;              %%%% wordrpt(0, '������', '����');   �½�word�ļ�
            Doc.PageSetup.TopMargin=60;  Doc.PageSetup.bottomMargin=50; 
            Doc.PageSetup.LeftMargin=50; Doc.PageSetup.RightMargin=50; 
            if nargin<2, var2=('PSINS���ݷ�������'); end;
            ActxWord.Selection.TypeParagraph;
            ActxWord.Selection.Start = Doc.Content.end;
            ActxWord.Selection.Text = var2;
            ActxWord.Selection.ParagraphFormat.Alignment = 'wdAlignParagraphCenter';  ActxWord.Selection.Font.Size = 20; ActxWord.Selection.Font.Bold = 1;
            ActxWord.Selection.Start = Doc.Content.end;
            ActxWord.Selection.TypeParagraph;
            if nargin<3, str=datestr(now,31); var3=(['by PSINS, ',str]); end;
            ActxWord.Selection.Start = Doc.Content.end;
            ActxWord.Selection.Text = var3;
            ActxWord.Selection.ParagraphFormat.Alignment = 'wdAlignParagraphCenter';  ActxWord.Selection.Font.Size = 12;
            ActxWord.Selection.Start = Doc.Content.end;
            ActxWord.Selection.TypeParagraph; ActxWord.Selection.TypeParagraph;
            figno = 1; figwh = [800; 600];
        elseif var1(1)==-1,
            if nargin<2, str=datestr(now,30); var2=sprintf('PSINS���ݷ���%s.docx',str(end-5:end)); end
            if isempty(strfind(var2,'.docx')), var2=[var2,'.docx']; end
            Doc.SaveAs2(var2); % Doc.Close; ActxWord.Quit(); ActxWord=[];  %%%% wordrpt(-1, '�ļ���.docx');  ����word�ļ�
        elseif length(var1)==2
            figwh = var1;                                                  %%%% wordrpt([800;600]);  ����ͼƬ��С           
        else
            ActxWord.Selection.Start = Doc.Content.end;
            set(var1, 'Position', [50 50 figwh(1) figwh(2)]);
            print(var1, '-dmeta'); %Ϊȥ��ͼ��Χ�հף�Win��ʼ->����->ϵͳ->��Ļ->�����벼��->100%
            ActxWord.Selection.Range.Paste;                                %%%% wordrpt(gcf, 'ͼ����');  ����figureͼ
%             print(gcf, '-djpeg', 'psins_tmp.jpg');    Doc.Shapes.AddPicture('psins_tmp.jpg');
            ActxWord.Selection.ParagraphFormat.Alignment = 'wdAlignParagraphCenter';
            ActxWord.Selection.Start = Doc.Content.end;
            ActxWord.Selection.TypeParagraph;
            ActxWord.Selection.Start = Doc.Content.end;   % ͼ�Զ����
            str=sprintf('ͼ%d', figno); figno=figno+1; if nargin==2, str=[str,'  ',var2]; end
            ActxWord.Selection.Text = str;
            ActxWord.Selection.ParagraphFormat.Alignment = 'wdAlignParagraphCenter';  ActxWord.Selection.Font.Bold = 1;
            ActxWord.Selection.Start = Doc.Content.end;
            ActxWord.Selection.TypeParagraph;
        end
    else
        if nargin==2
            ActxWord.Selection.Start = Doc.Content.end;
            ActxWord.Selection.paragraphs.OutlinePromote;
            ActxWord.Selection.Text = sprintf('%.1f %s', var2, var1);      %%%% wordrpt(txt, 1.1);  д���⣬������1.1
            ActxWord.Selection.Font.Size = 16;
            ActxWord.Selection.Start = Doc.Content.end;
            ActxWord.Selection.TypeParagraph;
        else                                   
            ActxWord.Selection.Start = Doc.Content.end;
            ActxWord.Selection.Text = var1;                                %%%% wordrpt(txt);  д����
            ActxWord.Selection.Font.Size = 12;
            ActxWord.Selection.Start = Doc.Content.end;
            ActxWord.Selection.TypeParagraph;
        end
    end