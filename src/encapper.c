/*
 * ** Copyright 2006 Brian Swetland. All rights reserved.
 * **
 * ** Redistribution and use in source and binary forms, with or without
 * ** modification, are permitted provided that the following conditions
 * ** are met:
 * ** 1. Redistributions of source code must retain the above copyright
 * **    notice, this list of conditions, and the following disclaimer.
 * ** 2. Redistributions in binary form must reproduce the above copyright
 * **    notice, this list of conditions, and the following disclaimer in the
 * **    documentation and/or other materials provided with the distribution.
 * ** 3. The name of the authors may not be used to endorse or promote products
 * **    derived from this software without specific prior written permission.
 * **
 * ** THIS SOFTWARE IS PROVIDED BY THE AUTHORS ``AS IS'' AND ANY EXPRESS OR
 * ** IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * ** OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * ** IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * ** INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * ** NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * ** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * ** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * ** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * ** THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <dirent.h>
#include <fcntl.h>

#include <sys/types.h>
#include <sys/stat.h>

#define DEFAULT_ENCAPDIR "/usr/local/encap"
#define DEFAULT_LOCALDIR "/usr/local/"
#define DEFAULT_TRACKDIR "/usr/local/encap/encapper/EncapDirs"
#define MAX_PATH_LEN 8192

/* operational flags & such*/
char *encapdir=DEFAULT_ENCAPDIR;
char *localdir=DEFAULT_LOCALDIR;
char *trackdir=DEFAULT_TRACKDIR;
int edlen;

/* directories within packages to permanently ignore; this can be
   augmented with an encap.exclude file in the package directory */
char *ignoredirs[] = {
    "Source",
    "EncapDirs",
    "encap.exclude",
    NULL
};

/* save on a ton of mallocs */
char src[MAX_PATH_LEN],dst[MAX_PATH_LEN],trk[MAX_PATH_LEN],buf[MAX_PATH_LEN*3];

/* operational flags */
int verbose = 0;
int force = 0; 
int initialize = 0;
int doremove = 0;


static void usage(char *name)
{
    fprintf(stderr,"\nEncapper v1.3, Copyright 1997, Brian J. Swetland. Share and Enjoy.\n");
    fprintf(stderr,"usage: %s [-v] [-c] [-f] {-[ari] module module ...}*\n",name);
    fprintf(stderr,"flags: -f   force\n");
    fprintf(stderr,"       -v   verbose\n");
    fprintf(stderr,"       -a   add modules\n");
    fprintf(stderr,"       -r   remove modules\n");
    fprintf(stderr,"       -i   init encap tree for module\n");
    fprintf(stderr,"       -c   clean out old links\n");
    exit(1);
}


char *subdirs[] = {
    "/bin",
    "/lib",
    "/man",
    "/man/man1",
    "/man/man2",
    "/man/man3",
    "/man/man4",
    "/man/man5",
    "/man/man6",
    "/man/man7",
    "/man/man8",
    "/info",
    "/etc",
    NULL
};

static void make_encap_dirs(char *top)
{
    int i;
    char *path;

    path = malloc(strlen(top)+strlen(encapdir)+32);
    
    sprintf(path,"%s/%s",encapdir,top);
    if (verbose) fprintf(stderr,"+ %s\n",path);
    if(mkdir(path,0755)){
	sprintf(buf,"E Could not mkdir(\"%s\",0755)",path);
	perror(buf);
    }
    for(i=0;subdirs[i];i++){
	sprintf(path,"%s/%s%s",encapdir,top,subdirs[i]);
	if(verbose) fprintf(stderr,"+ %s\n",path);
	if(mkdir(path,0755)){
            sprintf(buf,"E Could not mkdir(\"%s\",0755)",path);
            perror(buf);
	}
    }
}

static void do_link(char *src, char *dst)
{                
    struct stat sinfo;
    int isourlink = 0;
    int l;

    if(!lstat(dst,&sinfo)){
	if (sinfo.st_mode & S_IFLNK) {
                /* its a link; see if it's ours */
            if ((l=readlink(dst, buf, MAX_PATH_LEN))>-1) {
		buf[l] = '\0';
		isourlink = (strncmp(buf, encapdir, edlen)==0);
		if (isourlink && strcmp(buf, src)==0)
                        /* already linked */
                    return;
            }
	}
            /* destination exists */
	if(!force && !isourlink) {
                /* if we are not forceful,
                   we cannot toast it unless its our link */
            fprintf(stderr,"E existing destination \"%s\" (try -f)\n",dst);
	} else {
                /* we are forceful -- try to delete */
                /* check if it's a directory and bitch if it isn't empty */
            if(sinfo.st_mode & S_IFDIR) {
		if (rmdir(dst)) {
                    sprintf(buf, "E rmdir(\"%s\")",dst);
                    perror(buf);
		} else {
                    if(symlink(src,dst)){
                        sprintf(buf, "E symlink(\"%s\",\"%s\")",src,dst);
                        perror(buf);
                    }
		}
            } else {
                if(unlink(dst)){
                    sprintf(buf,"E unlink(\"%s\")",dst);
                    perror(buf);
                } else {
                    if(symlink(src,dst)){
                        sprintf(buf, "E symlink(\"%s\",\"%s\")",src,dst);
                        perror(buf);
                    }
                    else
                        if (verbose) fprintf(stderr, "+ %s -> %s\n", dst, src);
                }
            }
	}
    } else {
            /* nothing in the way. go for it */
	if(symlink(src,dst)){
            sprintf(buf, "E symlink(\"%s\",\"%s\")",src,dst);
            perror(buf);
	}
	else
            if (verbose) fprintf(stderr, "+ %s -> %s\n", dst, src);
    }
}

static void do_unlink(char *src, char *dst)
{
    struct stat sinfo;
    int l;
    
    if(!stat(dst,&sinfo)){
            /* destination exists */
	if(force){
            if(unlink(dst)){
		sprintf(buf, "E unlink(\"%s\")", dst);
		perror(buf);
            } 
            else
		if (verbose) fprintf(stderr,"- %s -> %s\n", dst, src);
	} else {
            if(sinfo.st_mode & S_IFLNK){
                    /* and it's a link */
		if((l = readlink(dst,buf,MAX_PATH_LEN*3-1)) != -1){
                    buf[l]=0;
                    if(!strcmp(src,buf)){
                            /* they match */
			if(unlink(dst)){
                            sprintf(buf, "E unlink(\"%s\")", dst);
                            perror(buf);
			} else {                            
                            if (verbose)
                                fprintf(stderr,"- %s -> %s\n", dst, src);
                        }
                    } else {
			fprintf(stderr,"E (%s) is not in this package (try -f)\n",dst);
                    }
		} else {
                    sprintf(buf,"E readlink(\"%s\")",dst);
                    perror(buf);
		}
            } else {
		fprintf(stderr, "E not a link \"%s\" (try -f)\n", dst);
            }
	}
    } else {
	if(verbose) {
            fprintf(stderr, "? destination already gone \"%s\"\n", dst);
	}
    }
}

static void load_excludes(char *src, char ***excludes, char **buffer)
{
    struct stat sinfo;
    int ex_fd,bytes,cnt,st;
    
        /* first, see if there's an encap.exclude file, and read it */
    strcpy(buf, src);
    strcat(buf, "/encap.exclude");
    
    *buffer = NULL;
    *excludes = NULL;
    
    if (stat(buf, &sinfo)==0) {
            /* Read the file */
	ex_fd = open(buf, O_RDONLY);
	if (ex_fd > -1) {
            *buffer = malloc(sinfo.st_size+1);
            if (*buffer) {
		bytes = 0;
		cnt = 1;
		while (cnt > 0 && bytes<sinfo.st_size) {
                    cnt = read(ex_fd, *buffer+bytes, sinfo.st_size-bytes);
                    if (cnt > 0) 
			bytes+=cnt;
		}
            }
            close(ex_fd);
            *buffer[sinfo.st_size] = '\0';
	}
            /* Now split it */
	if (*buffer) {
                /* Count the lines */
            for (cnt=0, bytes=0; bytes<sinfo.st_size; bytes++)
		if (*buffer[bytes] == '\n')  
                    cnt++;
                /* Allocate the pointers and split the buffer */
            *excludes = malloc((cnt+1)*sizeof(char*));
            if (*excludes) {
		for (cnt=0, bytes=0, st=0; bytes<sinfo.st_size; bytes++) {
                    if (*buffer[bytes] == '\n') {
			*excludes[cnt] = *buffer+st;
			*buffer[bytes] = '\0';
			st = bytes+1;
			cnt++;
                    }
		}
		*excludes[cnt] = NULL;
            }
	}
    }
}

static void free_excludes(char ***excludes, char **buffer)
{    
    /* deallocate the excludes list */
    if (*excludes)
	free(*excludes);
    if (*buffer)
	free(*buffer);
}


/* recursively symlink from destpath to path. build dirs as needed */
static void encap(void)
{
    struct stat sinfo;
    struct dirent *dinfo;
    DIR *dp;
    int s,d;
    int ignore, i;
    
    char *buffer;
    char **excludes;

    if(verbose)
	printf("%s:\n",src);

        /* does our destination exist? */
    if(stat(dst,&sinfo)){
	if(mkdir(dst,0755)){
            sprintf(buf,"E mkdir(\"%s\",0755)",dst);
            perror(buf);
            return;
	}
    } else if(!(sinfo.st_mode & S_IFDIR)){
	fprintf(stderr,"E \"%s\" is not a directory",dst);
	return;
    }

        /* so far so good.  got a source and dest dir. let's link 'em */

    load_excludes(src, &excludes, &buffer);
    
        /* walk the directory */
    if(!(dp = opendir(src))){
	sprintf(buf,"E Cannot opendir(\"%s\")",src);
	perror(buf);
	return;
    }

        /* save the name of this dir in our list of dirs */
    strcpy(buf, trackdir);
    strcat(buf, "/");
    strcat(buf, dst+strlen(localdir));
    mkdir(buf, 0755);

        /* tack on a '/' */
    strcat(dst,"/");
    strcat(src,"/");

    while((dinfo = readdir(dp))){

            /* as long as it's not "." or ".." ... */
	ignore = 0;
	if(strcmp(dinfo->d_name,".")==0 || strcmp(dinfo->d_name,"..")==0)
            ignore=1;

            /* ... or something in ignoredirs ... */
	for(i=0; ignoredirs[i]!=NULL; i++) {            
            if (strcmp(dinfo->d_name,ignoredirs[i])==0) {
		if (verbose) fprintf(stderr,"Ignoring directory %s\n", dinfo->d_name);
		ignore = 1;
            }
        }

            /* ... or something in excludes ... */
	if (excludes) {            
            for(i=0; excludes[i]!=NULL; i++) {                
		if (strcmp(dinfo->d_name,excludes[i])==0) {
                    if (verbose) 
			fprintf(stderr,"Excluding directory %s\n", dinfo->d_name);
                    ignore = 1;
		}
            }
        }

            /* ... then do the linking. */
	if (!ignore) {
                /* create full pathnames */
            s=strlen(src);
            d=strlen(dst);
            strcat(dst,dinfo->d_name);
            strcat(src,dinfo->d_name);

            if(stat(src,&sinfo)){
		sprintf(buf," Couldn't stat \"%s\"",src);
		perror(buf);
		continue;
            }
            
            if(sinfo.st_mode & S_IFDIR){
                    /* descend if it's a dir */
		encap();
            } else {
		if(doremove){    
                    do_unlink(src,dst);
		} else {
                    do_link(src,dst);
		}
            }       

                /* remove the name we tacked on */
            dst[d]=0;
            src[s]=0;
	}
    }
    closedir(dp);  

    free_excludes(&excludes, &buffer);
    
        /* remove the '/' added earlier */
    dst[strlen(dst)-1]=0;
    src[strlen(src)-1]=0;
}

/* do some spring cleaning. remove any links that are ours that don't
   exist anymore, and then remove any resulting empty directories. 
   we limit the search to directories we've touched before so that we
   don't have to search all of /usr/local (or whatever) */
static void do_inner_clean()
{
    int s;
    struct dirent *dinfo;
    struct stat sinfo;
    DIR *dir;
    int empty;
    int len;

    if (verbose) fprintf(stderr,"Cleaning %s...\n", src);

    strcat(src, "/");
    s = strlen(src);
    dir = opendir(src);
    if (!dir) {
	sprintf(buf, "E Could not open directory %s", src);
	perror(buf);
	return;
    }

    while ((dinfo=readdir(dir))) {
	if (strcmp(dinfo->d_name, ".") && strcmp(dinfo->d_name, "..")) {
            empty = 0;
                /* check the file */
            strcpy(src+s, dinfo->d_name);
            if (stat(src, &sinfo)) {
                    /* the file didn't exist; it's prolly a dead link */
		if (lstat(src, &sinfo)==0) 
                    if (sinfo.st_mode & S_IFLNK) 
                            /* it's a link; see if its ours */
			if ((len=readlink(src, dst, MAX_PATH_LEN))>-1) 
                            if (strncmp(dst, encapdir, edlen)==0) { 
				/* it's ours, nuke it */
				dst[len] = '\0';
				if (verbose) fprintf(stderr,"- %s -> %s\n", src, dst);
				if (unlink(src)) {
                                    sprintf(buf, "E unlink(%s)", src);
                                    perror(buf);
				}
                            }
            }	
#if 0
            else {
                    /* see if its a dir; if so, recurse */
		if (sinfo.st_mode & S_IFDIR) 
                    do_inner_clean();
            }
#endif
            src[s] = '\0';
	}
    }
    closedir(dir);

        /* If the directory is empty, then nuke it */
    empty = 1;
    dir = opendir(src);
    while (empty && (dinfo=readdir(dir))!=NULL) {
	if (strcmp(dinfo->d_name, ".") && strcmp(dinfo->d_name, ".."))
            empty = 0;
    }
    closedir(dir);

    if (empty) {
	if (verbose) fprintf(stderr, "removing %s\n", src);
	if (unlink(src)) {
            sprintf(buf, "E Could not remove %s", src);
            perror(buf);
	}
    }
}

/* look at the list of directories in trackdir, and clean the equivalents
   in localdir */
static void do_clean()
{
    int p;
    struct dirent *dinfo;
    DIR *dir;
    struct stat sinfo;

    p = strlen(trk);

    dir = opendir(trk);
    if (!dir) {
	sprintf(buf, "E Couldn't open %s", trk);
	perror(buf);
	return;
    }

        /* see if there are subdirs.  if so recurse. */
    while ((dinfo = readdir(dir))) {
            /* skip . and .. */
	if (strcmp(dinfo->d_name, ".") && strcmp(dinfo->d_name, "..")) {
                /* recurse */
            trk[p] = '/'; trk[p+1] = '\0';
            strcat(trk, dinfo->d_name);
            do_clean();
                /* clean */
            strcpy(src, localdir);
            strcat(src, trk+strlen(trackdir));
            if (stat(src, &sinfo)) {
		if (verbose) fprintf(stderr, "untracking %s\n", src);
		unlink(trk);
            }
            else
		do_inner_clean();
            trk[p] = '\0';
	}
    }
    closedir(dir);
}

int main(int argc, char *argv[])
{
    int i;
    char *p;

    umask(022);

    edlen = strlen(encapdir);

    if(argc==1)
	usage(argv[0]);
    
    for(i=1;i<argc;i++){
	if(argv[i][0]=='-'){
            p = &argv[i][1];
            while(*p){
		switch(*p){
		case 'v':
                    verbose++;
                    break;
		case 'f':
                    force++;
                    break;
		case 'i':
                    initialize++;
                    break;
		case 'a':
                    doremove = 0;
                    break;
		case 'r':
                    doremove = 1;
                    break;
		case 'c':
                    strcpy(trk, trackdir);
                    do_clean();
                    break;
		default:
                    fprintf(stderr,"Error: Invalid option \"%s\".\n",argv[i]);
                    usage(argv[0]);
		}
		p++;
            }
	} else {
                /* strip tailing slash */
            if(argv[i][strlen(argv[i])-1]=='/')
		argv[i][strlen(argv[i])-1]=0;

            if(strchr(argv[i],'/')){
		fprintf(stderr,"Error: Module names should not include '/'.\n");
		usage(argv[0]);
            }
                
            if(initialize) {
		make_encap_dirs(argv[i]);
            } else {
		sprintf(src,"%s/%s",encapdir,argv[i]);
		strcpy(dst,localdir);
		encap();
            }
	}
        
    }            
    return 0;
}

