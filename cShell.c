#include <unistd.h>
#include <sys/wait.h>

#define BUFF_SIZE 128

int main(int argc, char* argv[], char* envp[]) {

    char buf[BUFF_SIZE];
    
    while (1){

        write(1, "-> ", 3);

        int byte_read = read(0, buf, BUFF_SIZE - 1);


        // if not byte read then continue
        if (byte_read == 0){
            continue;
        }

        // replace newline with string terminator
        if (buf[byte_read - 1] == '\n'){
            buf[byte_read - 1] = 0;
        }
        int pid = fork();

        // child process
        if (pid == 0){ 

            char *n_argv[] = {buf,NULL};

            execve(buf,n_argv, envp);

            write(1, "Command not found :)\n",21);

        }
        // parent process
        else{ 
            wait(0);
        }

    }
    return 0;

}
