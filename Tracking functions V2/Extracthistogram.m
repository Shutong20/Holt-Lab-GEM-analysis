Hx = get(gco,'Xdata')
Hy = get(gco,'Ydata')

x2 = preDMSOx(2:4:end);
y2 = preDMSOy(2:4:end)-3.55;
y2 = y2/trapz(x2,y2);

x = DMSOx(2:4:end);
y = DMSOy(2:4:end)-1.55;
y = y/trapz(x,y);

x3 = controlx(2:4:end);
y3 = controly(2:4:end)-2.55;
y3 = y3/trapz(x3,y3);

x1 = Hx(2:4:end);
y1 = Hy(2:4:end)-0.55;
y1 = y1/trapz(x1,y1);

x4 = ix(2:4:end);
y4 = iy(2:4:end);
y4 = y4/trapz(x4,y4);
