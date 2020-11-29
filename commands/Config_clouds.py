#!/usr/bin/env python3
from os import path
import linecache
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk


class Config_clouds(Gtk.Window):
    def __init__(self):
        Gtk.Window.__init__(self)
        BASE_DIR = path.dirname(path.abspath(__file__))
        glade = path.join(BASE_DIR, "Config_clouds.glade")
        self.labels = []
        self.buttons = []
        self.builder = Gtk.Builder()
        self.builder.add_from_file(glade)
        self.builder.connect_signals(self)
        config_folder = path.expanduser('~/.config/clouds_applet_config/')
        self.config = config_folder + 'arguments.txt'
        self.cloud_cofig = config_folder + 'clouds_config.txt'
        self.window = self.builder.get_object("Config")
        self.parameters = self.builder.get_object("parameters")
        self.grid = self.builder.get_object("grid")
        self.name = self.builder.get_object("Name")
        self.selectfolder = self.builder.get_object("selectfolder")
        self.textbuffer = self.parameters.get_buffer()
        f = open(self.config, 'r')
        parameters = f.read()
        self.textbuffer.set_text(parameters)
        f.close()
        clouds_count = self.numLinesFile(self.cloud_cofig)
        for i in range(1, clouds_count + 1):
            new_label = linecache.getline(self.cloud_cofig, i).replace("\n", "")
            self.createWidgets(new_label, i)
        self.grid.show_all()
        self.selectfolder.set_action(Gtk.FileChooserAction.SELECT_FOLDER)
        self.window.connect('destroy', Gtk.main_quit)
        self.window.show_all()

    def createWidgets(self, label, i):
        self.buttons.append(Gtk.Button())
        self.buttons[i - 1].set_label('Delete')
        self.buttons[i - 1].connect('clicked', self.on_Delete_clicked)
        self.labels.append(Gtk.Label())
        self.labels[i - 1].set_text(label)
        self.grid.attach(self.buttons[i - 1], 2, i, 1, 1)
        self.grid.attach(self.labels[i - 1], 1, i, 1, 1)

    def numLinesFile(self, rute):
        numLines = -1
        try:
            archive = open(rute, 'r')
            numLines = len(archive.readlines())
            archive.close()
        except FileNotFoundError:
            print("the route no correct")
        return numLines

    def on_add_clicked(self, source):
        name = self.name.get_text()
        rute = self.selectfolder.get_file()
        if name and rute:
            mount_config = f'{name}:{rute.get_path()}'
            self.createWidgets(mount_config, len(self.labels) + 1)
            self.grid.show_all()

    def on_Save_config(self, source):
        Savechanges = Gtk.MessageDialog(parent=self,
                                        modal=True,
                                        destroy_with_parent=True,
                                        message_type=Gtk.MessageType.WARNING,
                                        text="Save all changes",
                                        buttons=Gtk.ButtonsType.OK_CANCEL)
        Savechanges.connect("response", self.dialog_response)
        Savechanges.show()

    def dialog_response(self, widget, response_id):
        if response_id == Gtk.ResponseType.OK:
            f = open(self.config, 'w')
            f.write(self.getText(self.parameters))
            f.close()
            data_clouds = "".join(i.get_text() + '\n' for i in self.labels)
            with open(self.cloud_cofig, 'w') as file:
                file.write(data_clouds)
        widget.destroy()

    def on_Delete_clicked(self, source):
        self.grid.remove_row(self.buttons.index(source) + 1)
        del self.labels[self.buttons.index(source)]
        self.buttons.remove(source)

    def getText(self, textview):
        buffer = textview.get_buffer()
        startIter, endIter = buffer.get_bounds()
        text = buffer.get_text(startIter, endIter, False)
        return text

    def init(self):
        Gtk.main()

    def on_window_destroy(self, *args):
        Gtk.main_quit()


if __name__ == "__main__":
    app = Config_clouds()
    app.init()
