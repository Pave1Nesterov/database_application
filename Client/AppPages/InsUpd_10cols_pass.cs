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

namespace Client
{
    public partial class InsUpd_10cols_pass : Form
    {
        private NpgsqlConnection _connection;
        private NpgsqlCommand _command;
        private Tools _tool;
        private string _table;
        private string _cur_event;
        public int _id;

        public InsUpd_10cols_pass()
        {
            InitializeComponent();
        }
        public InsUpd_10cols_pass(NpgsqlConnection conn, NpgsqlCommand comm, string table, string event_)
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

        public void setValues(string value1, string value2, string value3, string value4,
            DateTime value5, string value6, string value7, string value8, string value9, string value10)
        {
            textBoxLname.Text = value1;
            textBoxName.Text = value2;
            textBoxPatronymic.Text = value3;
            if (value4 == "М") radioButton1.Checked = true;
            else if (value4 == "Ж") radioButton2.Checked = true;
            dateTimePicker1.Value = value5;
            textBoxPassport.Text = value6;
            textBoxCode.Text = value7;
            textBoxEmail.Text = value8;
            textBoxPhone.Text = value9;
            textBoxBirthSert.Text = value10;
        }
        private void radioButton1_CheckedChanged(object sender, EventArgs e) => pictureBox1.BackgroundImage = Client.Properties.Resources.icon_passengerM;
        private void radioButton2_CheckedChanged(object sender, EventArgs e) => pictureBox1.BackgroundImage = Client.Properties.Resources.icon_passengerF;
        private void textBoxPassport_TextChanged(object sender, EventArgs e)
        {
            textBoxBirthSert.Clear();
            textBoxBirthSert.Text = null;
        }
        private void textBoxBirthSert_TextChanged(object sender, EventArgs e)
        {
            textBoxPassport.Clear();
            textBoxPassport.Text = null;
            textBoxEmail.Clear();
            textBoxEmail.Text = null;
            textBoxPhone.Clear();
            textBoxPhone.Text = null;
        }
        private void textBoxEmail_TextChanged(object sender, EventArgs e)
        {
            textBoxBirthSert.Clear();
            textBoxBirthSert.Text = null;
        }
        private void textBoxPhone_TextChanged(object sender, EventArgs e)
        {
            textBoxBirthSert.Clear();
            textBoxBirthSert.Text = null;
        }
        private void buttonApply_Click(object sender, EventArgs e)
        {
            string sex = "", passport, birth_sert, email, phone, patronymic;
            if (radioButton1.Checked) sex = "М";
            else if (radioButton2.Checked) sex = "Ж";
            if (textBoxPatronymic.Text != "") patronymic = string.Format("\'{0}\'", textBoxPatronymic.Text); else patronymic = "null";
            if (textBoxPassport.Text != "") passport = string.Format("\'{0}\'", textBoxPassport.Text); else passport = "null";
            if (textBoxBirthSert.Text != "") birth_sert = string.Format("\'{0}\'", textBoxBirthSert.Text); else birth_sert = "null";
            if (textBoxEmail.Text != "") email = string.Format("\'{0}\'", textBoxEmail.Text); else email = "null";
            if (textBoxPhone.Text != "") phone = string.Format("\'{0}\'", textBoxPhone.Text); else phone = "null";
            if (textBoxLname.Text == "" || textBoxName.Text == "" || textBoxCode.Text.ToUpper() == "" || radioButton1.Checked == false &&
                radioButton2.Checked == false || textBoxBirthSert.Text == "" && textBoxEmail.Text == "" && textBoxPhone.Text == "")
            {
                MessageBox.Show("Некоторые обязательные поля не заполнены!", "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            if (textBoxEmail.Text != "")
            {
                if (!(textBoxEmail.Text.Contains("@") && textBoxEmail.Text.Contains(".")))
                {
                    MessageBox.Show("Проверьте правильность заполнения поля \"email\"", "Предупреждение", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
            }
            if (_cur_event == "INSERT")
            {
                if (_tool.makeQuery(string.Format("SELECT insert_{0} (\'{1}\', \'{2}\', {3}, \'{4}\', \'{5}\', {6}, \'{7}\', {8}, {9}, {10});",
                    _table, textBoxLname.Text.Trim(), textBoxName.Text.Trim(), patronymic.Trim(), sex.Trim(),
                    dateTimePicker1.Text, passport.Trim(), textBoxCode.Text.ToUpper().Trim(), email.Trim(), phone.Trim(), birth_sert.Trim())))
                {
                    MessageBox.Show("Строка добавлена!", "Успешно!", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    textBoxLname.Clear();
                    textBoxName.Clear();
                    textBoxPatronymic.Clear();
                    radioButton1.Checked = false;
                    radioButton2.Checked = false;
                    pictureBox1.BackgroundImage = null;
                    textBoxPassport.Clear();
                    textBoxBirthSert.Clear();
                    textBoxCode.Clear();
                    textBoxEmail.Clear();
                    textBoxPhone.Clear();
                }
            }
            else
            {
                if (_tool.makeQuery(string.Format("SELECT update_{0} (\'{1}\', \'{2}\', \'{3}\', {4}, \'{5}\', \'{6}\', {7}, \'{8}\', {9}, {10}, {11});",
                    _table, _id, textBoxLname.Text.Trim(), textBoxName.Text.Trim(), patronymic.Trim(), sex.Trim(),
                    dateTimePicker1.Text, passport.Trim(), textBoxCode.Text.ToUpper().Trim(), email.Trim(), phone.Trim(), birth_sert.Trim())))
                {
                    MessageBox.Show("Строка изменена!", "Успешно!", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
            }
        }
    }
}