/*
* filename: yuv2header.c
* For a yuv444 or yuv422 file transform into header file  yuv*.h
* modify from utils_yuv444_out_header and utils_yuv422_out_header
*                                ---- hymicro 2017-3-31
*
* explain of argv[]:
*   argv[1]: the input *.yuv file name, such as lena_128_96_444.yuv
*   argv[2]: the format of argv[1] yuv file.
*   argv[3]: the output header file name
* [default argv[]]: yuvout_dispbuff.yuv yuv422 yuv_yuv422.h
*   default format is "yuv422", Be attention to the format must match with the argv[1] yuv file.
* if you have been input the yuv file name, should input the format, if no ,will be hand on with "yuv422"
*
* run example:
*   1> gcc yuv2header.c -o yuv2header
*   2> ./yuv2header Penguins_720p_444.yuv yuv444
* err example:
*   1>  ./yuv2header yuv444
*       <err> *.yuv file name err
*
*/
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <string.h>

#define     NAME_MAXLEN      (50)
#define     FPRINT_CMDOPT    fprintf(stdout, \
                                     "\n[cmdopt]:infile:%s\n\tinfmt:%s\n\toutfile:%s\n", \
                                     cmdopt->infile,cmdopt->infmt,cmdopt->outfile)

typedef struct{
    char *infile;
    char *infmt;
    char *outfile;
}yuv_cmdopt_type;

int main(int argc, char *argv[])
{
    FILE *fpin = NULL;
    FILE *fpout = NULL;
    unsigned int readtemp;
    unsigned int convtemp;
    unsigned int yuvdat = 0x0;
    int instr_count;
    yuv_cmdopt_type *cmdopt;
    char outname[NAME_MAXLEN]="yuv_";
    unsigned int yuv_offset;
    if( !(cmdopt = calloc(1,sizeof(yuv_cmdopt_type)) ) )
    {
        fprintf(stderr, "[err]: insufficient memory\n");
        exit(-1);
    }

    if (argc <= 4)
    {
        cmdopt->infile = (argc<2)?"yuvout_dispbuff.yuv":argv[1];
        cmdopt->infmt  = (argc<2)?"yuv422":argv[2];
        if(argc<=3)
        {
            strcat(outname,cmdopt->infmt);
            strcat(outname,".h");
            cmdopt->outfile = outname;
        }
        else
        {
            cmdopt->outfile = argv[3];
        }
        FPRINT_CMDOPT;
    }
    else
    {
        fprintf(stderr, "[err]: yuv_cmdopt argc input err\n");
        exit(-1);
    }

    if(!strcmp(cmdopt->infmt,"yuv422"))
    {
        yuv_offset = 2;
    }
    else if(!strcmp(cmdopt->infmt,"yuv444"))
    {
        yuv_offset = 3;
    }
    else{
        fprintf(stderr, "[err]: %s input err\n",cmdopt->infmt);
        exit(-1);
    }

    fpin = fopen(cmdopt->infile, "rb");
    if (fpin == NULL)
    {
        fprintf(stderr, "[err]: open %s file err",cmdopt->infile);
        exit(-1);
    }

    fpout = fopen(cmdopt->outfile, "w");
    if (fpout == NULL)
    {
        fprintf(stderr, "[err]: open %s file err",cmdopt->infile);
        exit(-1);
    }

    //Determine the length of this file
    fseek(fpin, 0, SEEK_END);
    instr_count = ftell(fpin);
    fseek(fpin, 0, SEEK_SET);
    printf("input file size : %d Byte\n", instr_count);

    fprintf(fpout, "//#include\"debug_yuvdat.h\"\n\n");
    fprintf(fpout, "#ifndef __DEBUG_YUVDAT_H__\n");
    fprintf(fpout, "#define __DEBUG_YUVDAT_H__\n\n");
    fprintf(fpout, "#define DEBUG_YUVDAT_LEN  (%d)\n", instr_count / yuv_offset);
    fprintf(fpout, "\nconst unsigned int debug_yuvdat[DEBUG_YUVDAT_LEN]={\n");

    instr_count = 0;
    while (fread(&readtemp, yuv_offset, 1, fpin) == 1)
    {
        if(3==yuv_offset) //fmt yuv444
        {
            convtemp = readtemp & 0x0000ff00;
            convtemp |= (readtemp & 0x000000ff) << 16;
            convtemp |= (readtemp & 0x00ff0000) >> 16;
        }
        else //fmt yuv422
        {
            convtemp  = (readtemp & 0x0000ff00)>>8;
            convtemp |= (readtemp & 0x000000ff)<<8;
        }
        yuvdat = convtemp;
        instr_count++;
        fprintf(fpout, "0x%08x, ", yuvdat);
        if (0 == (instr_count % 20))
        {
            fprintf(fpout, "\n");
        }
        if (instr_count == 1)
        {
            printf("first yuvdat = %08x\n", yuvdat);
        }
    }
    if (0 == (instr_count % 20)) // has been printf ',\n'
    {
        fseek(fpout, -4L, SEEK_CUR);
    }
    else //just has been  printf ','
    {
        fseek(fpout, -2L, SEEK_CUR);
    }
    fprintf(fpout, "}; /*%d elements*/\n", instr_count);
    fprintf(fpout, "\n#endif /*----end of file----*/\n");


    printf("/*%d elements*/\n", instr_count);
    puts("ok");

    fclose(fpin);
    fclose(fpout);
    free(cmdopt);

    return 0;
}

