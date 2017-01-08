FROM debian:jessie

ENV LANG C.UTF-8

RUN apt-get update && \
    apt-get install -y sudo g++ git vim curl wget exuberant-ctags build-essential ca-certificates \
                       libcurl4-openssl-dev zlib1g-dev libtinfo-dev libsqlite3-0 libsqlite3-dev

RUN wget -q -O- https://s3.amazonaws.com/download.fpcomplete.com/debian/fpco.key | apt-key add -
RUN echo 'deb http://download.fpcomplete.com/debian/jessie stable main'| tee /etc/apt/sources.list.d/fpco.list

RUN apt-get update && apt-get install -y stack

RUN apt-get clean

ADD https://raw.githubusercontent.com/begriffs/haskell-vim-now/master/install.sh /install.sh
RUN bash /install.sh

RUN sed -i -e '/ConcealPlus/d' -e '/airline_powerline_fonts/d' /root/.vimrc

RUN echo ':set prompt "λ> "\n:set prompt2 "λ| "\n:set editor vim' > /root/.ghci

RUN cd /root/.local/bin && \
    mv ghc-mod ghc-mod.bin && \
    mv ghc-modi ghc-modi.bin

RUN cd /root/.local/bin && \
    echo '#!/bin/bash\n$0.bin $@ 2>/dev/null' > wrapper.sh && \
    chmod +x wrapper.sh && \
    ln -sv wrapper.sh ghc-mod && \
    ln -sv wrapper.sh ghc-modi

ENV PATH /root/.local/bin:$PATH

WORKDIR /work

CMD ["stack", "ghci"]
# Manually do :PlugUpdate in vim
