using Npgsql;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Windows.Forms.VisualStyles;

namespace Client
{
    public partial class InsUpd_10cols_ticket : Form
    {
        private NpgsqlConnection _connection;
        private NpgsqlCommand _command;
        private Tools _tool;
        private string _table;
        private string _cur_event;
        public int _id;
        private string[] person;
        private string[] railway_trip;
        private string[] tariff;
        public InsUpd_10cols_ticket()
        {
            InitializeComponent();
        }
        public InsUpd_10cols_ticket(NpgsqlConnection conn, NpgsqlCommand comm, string table, string event_)
        {
            InitializeComponent();
            _tool = new Tools(conn);
            _connection = conn;
            _command = comm;
            _table = table;
            _cur_event = event_;
        }
        public void setButtonText(string _text)
        {
            if (_cur_event == "INSERT")
            {
                buttonApply.Text = "Добавить строку";
            }
            else if (_cur_event == "UPDATE")
            {
                buttonApply.Text = "Изменить строку";
            }
        }
        public void setValues(string value1, string value2, string value3,
            string value4, string value5, string value6,
            string value7, string value8, bool value9, bool value10, string value11,
            string value12, DateTime value13, string value14, DateTime value15, string value16, string value17, string value18)
        {
            comboBoxPassenger.Text = value1 + " " + value2 + " " + value3;
            comboBoxTrip.Text = value4 + ", " + value5 + ", " + value6;
            comboBoxTariff.Text = value7 + ", " + value8 + ", " + value9 + ", " + value10 + ", " + value11;
            textBoxDeppoint.Text = value12;
            dateTimePickerDep.Value = value13;
            textBoxArrpoint.Text = value14;
            dateTimePickerArr.Value = value15;
            textBoxCarriage.Text = value16;
            textBoxSeat.Text = value17;
            textBoxPrice.Text = value18;
        }
        private void buttonApply_Click(object sender, EventArgs e)
        {
            person = comboBoxPassenger.Text.Split(' ');

            if (person[2] != "") person[2] = String.Format("= \'{0}\'", person[2]); else person[2] = "IS NULL";
            int fk_1 = Convert.ToInt32(_tool.displayQuery(string.Format("SELECT id FROM passenger WHERE last_name = \'{0}\' AND name = \'{1}\' AND patronymic {2};",
                person[0], person[1], person[2])).Rows[0][0]);
            railway_trip = comboBoxTrip.Text.Split(',');
            for (int i = 0; i < 3; i++) railway_trip[i] = railway_trip[i].Trim();
            int fk_2 = Convert.ToInt32(_tool.displayQuery(string.Format("SELECT rt.id FROM railway_trip AS rt JOIN train AS t ON rt.train_id = t.id " +
                "WHERE number = \'{0}\' AND carriage_count = \'{1}\' AND passengers_count = \'{2}\';",
                railway_trip[0], railway_trip[1], railway_trip[2])).Rows[0][0]);
            tariff = comboBoxTariff.Text.Split(',');
            for (int i = 1; i < 5; i++) tariff[i] = tariff[i].Remove(0, 1);
            int fk_3 = Convert.ToInt32(_tool.displayQuery(string.Format("SELECT t.id FROM tariff AS t JOIN tariff_description td on t.description_id = td.id " +
                "JOIN service_class sc on t.service_class_id = sc.id JOIN discount_category dc on dc.id = t.discount_category_id " +
                "WHERE description = \'{0}\' AND class = \'{1}\' AND bed_linen = \'{2}\' AND insurance = \'{3}\' AND category = \'{4}\';",
                tariff[0], tariff[1], tariff[2], tariff[3], tariff[4])).Rows[0][0]);

            if (textBoxDeppoint.Text == "" || textBoxArrpoint.Text == "" || textBoxCarriage.Text == "" || textBoxSeat.Text == "" || textBoxPrice.Text == "")
            {
                MessageBox.Show("Некоторые обязательные поля не заполнены!", "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            if (_cur_event == "INSERT")
            {
                if (_tool.makeQuery(string.Format("SELECT insert_{0} (\'{1}\', \'{2}\', \'{3}\', \'{4}\', \'{5}\', \'{6}\', \'{7}\', \'{8}\', \'{9}\', \'{10}\');",
                    _table, fk_1, fk_2, fk_3, textBoxDeppoint.Text, textBoxArrpoint.Text, dateTimePickerDep.Value, dateTimePickerArr.Value,
                    textBoxCarriage.Text.Trim(), textBoxSeat.Text.Trim(), textBoxPrice.Text.Trim())))
                {
                    MessageBox.Show("Строка добавлена!", "Успешно!", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    textBoxDeppoint.Clear();
                    textBoxArrpoint.Clear();
                    textBoxCarriage.Clear();
                    textBoxSeat.Clear();
                    textBoxPrice.Clear();
                    comboBoxPassenger.SelectedIndex = -1;
                    comboBoxTrip.SelectedIndex = -1;
                    comboBoxTariff.SelectedIndex = -1;
                }
            }
            else
            {
                if (_tool.makeQuery(string.Format("SELECT update_{0} ({1}, {2}, {3}, {4}, \'{5}\', \'{6}\', \'{7}\', \'{8}\', \'{9}\', \'{10}\', \'{11}\');",
                    _table, _id, fk_1, fk_2, fk_3, textBoxDeppoint.Text, textBoxArrpoint.Text, dateTimePickerDep.Value, dateTimePickerArr.Value,
                    textBoxCarriage.Text.Trim(), textBoxSeat.Text.Trim(), textBoxPrice.Text.Trim())))
                {
                    MessageBox.Show("Строка изменена!", "Успешно!", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
            }
        }
        private void InsUpd_10cols_ticket_Load(object sender, EventArgs e)
        {
            foreach (DataRow row in _tool.displayQuery("SELECT * FROM passenger;").Rows)
            {
                comboBoxPassenger.Items.Add(row[1] + " " + row[2] + " " + row[3]);
            }
            foreach (DataRow row in _tool.displayQuery("SELECT number, carriage_count, passengers_count " +
                "FROM railway_trip JOIN train ON railway_trip.train_id = train.id;").Rows)
            {
                comboBoxTrip.Items.Add(row[0] + ", " + row[1] + ", " + row[2]);
            }
            foreach (DataRow row in _tool.displayQuery("SELECT description, class, bed_linen, insurance, category " +
                "FROM tariff AS tff JOIN tariff_description AS td ON tff.description_id = td.id " +
                "JOIN service_class sc on tff.service_class_id = sc.id " +
                "JOIN discount_category AS dc ON tff.discount_category_id = dc.id;").Rows)
            {
                comboBoxTariff.Items.Add(row[0] + ", " + row[1] + ", " + row[2] + ", " + row[3] + ", " + row[4]);
            }
        }
    }
}