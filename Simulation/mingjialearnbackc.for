c
c      mingjialearnbackc.for
c      constrain the low, med, and high values as proportional to the 
c       objective average dot displacements
c      adapt model to predict learning curves
c
c      start simple will all parms held fixed
c       except allow background noise to decay linearly with trial number
c      for comparability with previously reported fits, use Gaussian similarity
c      and now allow sensitivity to grow linearly with trial number up to an aymptote
c
       subroutine model(is1,nsim,ndim,abase,theory)
c
       double precision abase(50),theory(2,15)
       double precision pran,z,sum(3),s,d,val(3)
       double precision prot(3,9),train(2,3,75,9)
       double precision probcor(2,15)
       double precision c,back,backstart,backslope,gamma
       double precision cstart,cslope
       integer ntrain(2),catvect(2,225),order(15)
       real low,med,high,nrep(2),patvect(2,225,9)
       integer cntpat(3)
c
       ntrain(1)=5
       ntrain(2)=75
       nrep(1)=15
       nrep(2)=1
       do 2 i=1,15
2      order(i)=i
c
c      will start by holding first four parameters fixed at 
c       best-fitting values for class transfer data
c        from Gaussian model
c
       between=4.000
       scale=0.301
       low=scale*1.20
       med=scale*2.80
       high=scale*4.60
c       c=0.491
       gam=1.000
       backstart=abase(1)
       backslope=.01*abase(2)
       cstart=abase(3)
       cslope=abase(4)
c
       do 10 icond=1,2
       do 10 iblk=1,15
       theory(icond,iblk)=0
10     continue
c
       do 5000 isim=1,nsim
c
c      initialize probcor for this simulation
c
       do 15 irep=1,2
       do 15 iblk=1,15
       probcor(irep,iblk)=0
15     continue
c
c      create the patterns for this simulation
c
       do 21 icat=1,3
       do 20 m=1,ndim
       call rand(is1,pran)
       prot(icat,m)=between*pran
20     continue
21     continue
c
       do 50 icond=1,2
       do 30 icat=1,3
       do 25 ipat=1,ntrain(icond)
       do 22 m=1,ndim
       call rand(is1,pran)
       call zscor(pran,z)
       train(icond,icat,ipat,m)=prot(icat,m)+med*z
22     continue
25     continue
30     continue
50     continue
c
c      place the patterns in sequential learning vectors
c
c       REPEAT cond
       irep=1
       itrl=0
       do 80 iblk=1,15
       call permut(is1,15,order)
       do 70 k=1,15
       itrl=itrl+1
       kcat=(order(k)-1)/5+1
       catvect(1,itrl)=kcat
       kpat=order(k)-5*(kcat-1)
       do 60 m=1,ndim
60     patvect(irep,itrl,m)=train(irep,kcat,kpat,m)
70     continue
80     continue
c
c      NREP cond
       irep=2
       itrl=0
       do 90 k=1,3
90     cntpat(k)=0
       do 150 iblk=1,15
       call permut(is1,15,order)
       do 140 k=1,15
       itrl=itrl+1
       kcat=(order(k)-1)/5+1
       catvect(2,itrl)=kcat
       cntpat(kcat)=cntpat(kcat)+1
       do 130 m=1,ndim
130    patvect(irep,itrl,m)=train(irep,kcat,cntpat(kcat),m)
140    continue
150    continue
c
c      and now compute p(correct) for the simulated sequences
c
       do 500 irep=1,2
c
c
       do 400 itrl=1,225
       back=backstart-backslope*float(itrl)
       if (back .lt. 0) back=0
       c=cstart+cslope*float(itrl)
       if (c .gt. .491) c=.491
c
       iblk=(itrl-1)/15+1
       do 210 k=1,3
210    sum(k)=back
       icat=catvect(irep,itrl)
       if (itrl .eq. 1) go to 291
       do 290 j=1,itrl-1
       d=0
       do 280 m=1,ndim
280    d=d+(patvect(irep,itrl,m)-patvect(irep,j,m))**2
c
c      use Gaussian similarity by commenting out dsqrt
c       d=dsqrt(d)
c
       s=dexp(-c*d)
       jcat=catvect(irep,j)
       sum(jcat)=sum(jcat)+s
290    continue
       pc=(sum(icat)**gam)/(sum(1)**gam+sum(2)**gam+sum(3)**gam)
       go to 400
291    pc=.33
400    probcor(irep,iblk)=probcor(irep,iblk)+pc/15.
500    continue
c
       do 4000 irep=1,2
       do 4000 iblk=1,15
       theory(irep,iblk)=theory(irep,iblk)+probcor(irep,iblk)/
     .                                         float(nsim)
4000   continue
c
5000   continue
       return
       end
c
       subroutine permut(is1,n,order)
       double precision pran
       integer order(15)
       do 10 k=1,15
       call rand(is1,pran)
       iloc=n*pran+1
       itemp=order(k)
       order(k)=order(iloc)
       order(iloc)=itemp
10     continue
       return
       end
