/*
* For a yuv422 file transform into header file  yuv422*.h
* 
*                                ---- hymicro 2017-3-16
* 
* run example: 
*   1> gcc utils_yuv422_out_header.c -o utils_yuv422_out_header
*   2> ./utils_yuv422_out_header Penguins_720p_422.yuv
* err example:
*   1>  ./utils_yuv422_out_header
*       <err> argc != 2 ...
*
*/

#include <stdio.h>
#include <stdlib.h>

//#define   __DEBUG

#ifdef __DEBUG
#define INFILE_NAME "yuvout_dispbuff.yuv" /*debug use*/
#endif

#define OUTFILE_NAME "yuv422_yuyv_dat.h"

int main(int argc, char *argv[])
{

    FILE *fpin = NULL;
    FILE *fpout = NULL;
    unsigned char or32_instr;
    unsigned int yuvdat = 0x0;
    int instr_count;
#ifndef __DEBUG
    char *INFILE_NAME;

    if (argc != 2)
    {
        puts("<err> argc != 2 ");
        puts("<err> Please enter the *.bin file name");
        puts("<hlp> Such as : ./ultils_bin2header bootsz.bin");
        return -1;
    }
    INFILE_NAME = argv[1];
#endif
    fpin = fopen(INFILE_NAME, "rb");
    if (fpin == NULL)
    {
        puts("open bin file err");
        return -1;
    }

    fpout = fopen(OUTFILE_NAME, "w");
    if (fpout == NULL)
    {
        puts("open out file err");
        return -1;
    }

    // the very first word in flash is used. Determine the length of this file
    fseek(fpin, 0, SEEK_END);
    instr_count = ftell(fpin);
    fseek(fpin, 0, SEEK_SET);
    printf("input file size : %d Byte\n", instr_count);

    fprintf(fpout, "#ifndef __YUV422_YUYV_DAT_H__\n"); //yuv422_yuyv_dat
    fprintf(fpout, "#define __YUV422_YUYV_DAT_H__\n\n");
    fprintf(fpout, "#define    YUV422DAT_LEN    (%d)\n", instr_count / 2);
    fprintf(fpout, "\nconst unsigned int yuv422dat[YUV422DAT_LEN]={\n");

    instr_count = 0;
    while (fread(&or32_instr, 1, 1, fpin) == 1)
    {
        yuvdat = or32_instr << 8;
        if(fread(&or32_instr, 1, 1, fpin) != 1)
        {
            break;
        }
        yuvdat |= or32_instr;
        instr_count++;
        fprintf(fpout, "0x%08x, ", yuvdat);
        if (0 == (instr_count % 20))
        {
            fprintf(fpout, "\n");
        }
        if (instr_count == 1)
        {
            printf("or32_instr = %08x\n", yuvdat);
        }
    }
    if(0 == (instr_count % 20))  // has been printf ',\n'
    {
        fseek(fpout, -4L, SEEK_CUR);
    }
    else    //just has been  printf ','
    {
        fseek(fpout, -2L, SEEK_CUR);
    }
    fprintf(fpout, "}; /*%d elements*/\n", instr_count);
    fprintf(fpout, "\n#endif /*----end of file----*/\n");

    fclose(fpin);
    fclose(fpout);

    printf("/*%d elements*/\n", instr_count);
    puts("ok");
    return 0;
}
